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

    course1_with_id = createCourse("241", "math 208", "Differential Equations and Linear Algebra", "F31")
    course2_with_id = createCourse("241", "math 208", "Differential Equations and Linear Algebra", "F32")
    course3_with_id = createCourse("241", "math208", "Differential Equations and Linear Algebra", "F31")
    @test course1_with_id.course_id != course2_with_id.course_id
    @test course1_with_id.course_id == course3_with_id.course_id
    @test length(course1_with_id.students) == 0


    students_courses = addStudents(course1, csv_file_path;
        fields=Dict(:id => "external_id", :name => ("first_name", x -> uppercasefirst(x)), :email => ("external_id", x -> "s$(x)@kfupm.edu.sa"))
    )
    @test students_courses.course_id == course1_with_id.course_id
    @test isa(students_courses.students, Vector{Student})
    @test length(students_courses.students) > 0

    math557_course = createCourse("241", "MATH557", "Applied Linear Algebra", 1)
    math557_students = addStudents(math557_course.course, xlsx_file_path, "Class List Summary";
        first_row=15, fields=Dict(:id => "ID", :name => "Student Name", :email => ("ID", x -> "g$(x)@kfupm.edu.sa"))
    )
    @test length(math557_students.students) > 0

    # student_id = 202408140
    # student = Student(student_id)
    # @test isa(student, Student)
    # @test student.name == "Joud"

    # course = Course("MATH208", "141", "F31")
    # @test isa(course, Course)
    # @test length(course.students) == 26
    # @test course.term == "141"


    # grades_grade_scope_file = "data/gradescope.csv"
    # grades = Grade("MATH208", "141", "F31", "Class Test 1", grades_grade_scope_file
    #     ; mapping=Dict(:student_id => "SID", :value => "Total Score", :max_value => "Max Points"))
    # @test isa(grades, Vector{Grade})

end
