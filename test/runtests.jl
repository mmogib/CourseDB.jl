using KFUPMCourseDB
using DataFrames
using Test

@testset "KFUPMCourseDB.jl" begin
    reset_db()
    csv_file_path = "data/dfile.csv"
    csv_data = readdata(csv_file_path)
    @test isa(csv_data, FileData)
    @test length(csv_data.fields) == 7
    @test nrow(csv_data.data) == 27

    xlsx_file_path = "data/dfile.xlsx"
    xlsx_data = readdata(xlsx_file_path, "Class List Summary"; first_row=15)
    @test isa(xlsx_data, FileData)
    @test length(xlsx_data.fields) == 8
    @test nrow(xlsx_data.data) == 31


    csv_not_exist = "data/dum.csv"
    @test_throws AssertionError readdata(csv_not_exist)

    course1 = Course("241", "math 208", "Differential Equations and Linear Algebra", "F31")
    course2 = Course("241", "math 208", "Differential Equations and Linear Algebra", "F32")
    course4 = Course(241, "math 208", "Differential Equations and Linear Algebra", 31)
    course5 = Course("241", "math 208", "Differential Equations and Linear Algebra", 31)
    course6 = Course(241, "math 208", "Differential Equations and Linear Algebra", "31")
    @test isa(course1, Course)
    @test course1.code == "MATH208"
    @test course4.term == "241" && course4.section == "31"
    @test course5.term == "241" && course5.section == "31"
    @test course6.term == "241" && course6.section == "31"
    @test course1.id == "new"
    @test course1.students == []

    course1_with_id = createCourse("241", "math 208", "Differential Equations and Linear Algebra", "F31")
    course2_with_id = createCourse("241", "math 208", "Differential Equations and Linear Algebra", "F32")
    course3_with_id = createCourse("241", "math208", "Differential Equations and Linear Algebra", "F31")
    @test course1_with_id.id != course2_with_id.id
    @test course1_with_id.id == course3_with_id.id
    @test length(course1_with_id.students) == 0


    students_courses = addStudents(course1, csv_file_path;
        fields=Dict(:id => "external_id", :name => ("first_name", x -> uppercasefirst(x)), :email => ("external_id", x -> "s$(x)@kfupm.edu.sa"))
    )
    @test students_courses.id == course1_with_id.id
    @test isa(students_courses.students, Vector{Student})
    @test length(students_courses.students) > 0

    math557_course = createCourse("241", "MATH557", "Applied Linear Algebra", 1)
    math557_students = addStudents(math557_course, xlsx_file_path, "Class List Summary";
        first_row=15, fields=Dict(:id => "ID", :name => "Student Name", :email => ("ID", x -> "g$(x)@kfupm.edu.sa"))
    )
    @test length(math557_students.students) > 0

    @test isa(ids(math557_students), Vector{Int})
    @test isa(names(math557_students), Vector{String})
    @test isa(emails(math557_students), Vector{String})

    @test length(ids(course1)) == 0
    @test length(names(course1)) == 0
    @test length(emails(course1)) == 0

    s = Student(201120940, "Mohammed Alshahrani", "mshahrani@kfupm.edu.sa")
    # println(math557_students)
    # println(course1)
    grades_grade_scope_file = "data/gradescope.csv"
    math377 = createCourse(233, "MATH 377", "Numerical Computation", 1)
    math377 = addStudents(math377, grades_grade_scope_file;
        fields=Dict(:id => "SID", :name => "Name", :email => "Email")
    )
    math377 = addGrades(math377, grades_grade_scope_file,
        fields=Dict(
            :sid => "SID",
            :name => ("SID", _ -> "class_test_1"),
            :value => "Total Score",
            :max_value => "Max Points",
        )
    )
    math377_grades = getGrades(math377)
    math377_grades_with_name = getGrades(math377, "class_test_1")
    # println(math377_grades_with_name)
    @test isa(math377_grades, Vector{Grade}) && isa(math377_grades_with_name, Vector{Grade})
    math377_students = math377.students
    st_df = DataFrame(math377_students)
    @test isa(st_df, DataFrame) && nrow(st_df) == length(math377_students)

    filepath = "export/students.csv"
    result = writedata(filepath, math377_students; quotestrings=true)
    @test length(result.data) == length(math377_students)

    filepath = "export/students.txt"
    result = writedata(filepath, math377_students; quotestrings=true)
    @test length(result.data) == length(math377_students)

    filepath = "export/students.xlsx"
    result = writedata(filepath, math377_students; sheetname="students", overwrite=true)
    @test length(result.data) == length(math377_students)


    filepath = "export/grades.csv"
    result = writedata(filepath, math377_grades; quotestrings=true)
    @test length(result.data) == length(math377_grades)

    filepath = "export/grades.txt"
    result = writedata(filepath, math377_grades; quotestrings=true)
    @test length(result.data) == length(math377_grades)

    filepath = "export/grades.xlsx"
    result = writedata(filepath, math377_grades; sheetname="grades", overwrite=true)
    @test length(result.data) == length(math377_grades)


    # filepath = "export/students.csv"
    # result = writedata(filepath, math377_students)
    # @test length(result.data) == length(math377_students)
end
