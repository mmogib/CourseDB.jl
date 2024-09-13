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

    course = Course("MATH208", "141", "F31", csv_data.data, Dict(:id => "external_id", :name => "first_name", :email => "email"))
    @test isa(course, Course)

    student_id = 202408140
    student = Student(student_id)
    @test isa(student, Student)
    @test length(student.courses) == 1
    @test student.name == "Joud"

    course_id = "141MATH208F31"
    course = Course(course_id)
    @test isa(course, Course)
    @test length(course.students) == 26
    @test course.term == "141"

end
