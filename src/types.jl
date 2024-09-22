"""
    FileData(path::String, fields::Dict{String, String}, data::DataFrame)

A structure representing data loaded from a file, along with metadata about its fields.

# Fields
- `path::String`: The file path from which the data was read.
- `fields::Dict{String, String}`: A dictionary mapping column names to their data types. The keys are the column names (as strings), and the values are either `"number"` or `"string"`, indicating the type of data in each column.
- `data::DataFrame`: The actual data loaded from the file, stored as a `DataFrame`.

# Example
```julia
file_data = FileData("students.csv", Dict("id" => "number", "name" => "string"), DataFrame())
println(file_data.path)    # Prints the file path
println(file_data.fields)  # Prints the fields dictionary
println(file_data.data)    # Prints the DataFrame
```
"""
struct FileData
    path::String
    fields::Dict{String,String}
    data::DataFrame
end

"""
    Student(id::Int, name::String, email::String)

A structure representing a student with their basic details.

# Fields
- `id::Int`: The student's unique identifier, typically a numeric value.
- `name::String`: The student's full name.
- `email::String`: The student's email address.

# Example
```julia
student = Student(12345, "John Doe", "johndoe@example.com")
println(student.id)    # Prints the student ID
println(student.name)  # Prints the student name
println(student.email) # Prints the student email
```
"""
struct Student
    id::Int
    name::String
    email::String
end
Base.show(io::IO, s::Student) = print(io, "ID:\t\t $(s.id)\nName:\t\t $(s.name)\nEMAIL:\t\t $(s.email)")
Base.show(io::IO, ss::Vector{Student}) = begin
    if length(ss) == 0
        print(io, "No students ...")
    else
        ids = map(x -> x.id, ss)
        names = map(x -> x.name, ss)
        emails = map(x -> x.email, ss)
        T = stack([ids, names, emails])
        pretty_table(io, T; header=["ID", "NAME", "EMAIL"], alignment=[:c, :l, :l])
    end
end
Base.getindex(s::Student, fld::Symbol) = getfield(s, fld)

"""
    Course

A structure representing a course, with multiple constructors for creating `Course` objects in various formats.

# Fields
- `id::Union{String, Int}`: A unique identifier for the course, which can either be a string (default is `"new"`) or an integer (after the course is created in the database).
- `term::String`: The academic term in which the course is offered, represented as a string (e.g., `"241"`).
- `code::String`: The course code (e.g., `"MATH371"`) with spaces removed and converted to uppercase.
- `name::String`: The full name of the course (e.g., `"Introduction to Numerical Computing"`).
- `section::String`: The section number of the course, represented as a string.
- `students::Vector{Student}`: A list (vector) of students enrolled in the course.

# Constructors
- `Course(term::String, code::String, name::String, section::String)`: Creates a new `Course` with the term, code, name, and section as strings, initializing `id` to `"new"` and `students` to an empty array.
- `Course(term::Integer, code::String, name::String, section::Integer)`: Creates a new `Course` with an integer term and section, with the code converted to uppercase and spaces removed.
- `Course(term::Integer, code::String, name::String, section::String)`: Creates a new `Course` with an integer term, string section, and processes the course code similarly.
- `Course(term::String, code::String, name::String, section::Integer)`: Creates a `Course` with a string term and an integer section.
- `Course(c::Course, id::Int)`: Creates a new `Course` with an updated ID while retaining all other attributes of the existing `Course` object.
- `Course(c::Course, students::Vector{Student})`: Creates a new `Course` by updating the list of students, while keeping all other course information the same.

# Example
```julia
course = Course(241, "MATH 371", "Introduction to Numerical Computing", 1)
println(course.code)  # Prints "MATH371"
println(course.id)    # Prints "new"
```
"""
struct Course
    id::Union{String,Int}
    term::String
    code::String
    name::String
    section::String
    students::Vector{Student}
    function Course(t::String, c::String, name::String, sec::String)
        code = replace(c, " " => "") |> uppercase
        new("new", t, code, name, sec, [])
    end
    function Course(t::Integer, c::String, name::String, sec::Integer)
        code = replace(c, " " => "") |> uppercase
        new("new", "$t", code, name, "$sec", [])
    end
    function Course(t::Integer, c::String, name::String, sec::String)
        code = replace(c, " " => "") |> uppercase
        new("new", "$t", code, name, sec, [])
    end
    function Course(t::String, c::String, name::String, sec::Integer)
        code = replace(c, " " => "") |> uppercase
        new("new", t, code, name, "$sec", [])
    end
    function Course(c::Course, id::Int)
        new(id, c.term, c.code, c.name, c.section, c.students)
    end
    function Course(c::Course, students::Vector{Student})
        new(c.id, c.term, c.code, c.name, c.section, students)
    end
end
Base.show(io::IO, c::Course) = begin
    print(io, "TERM:\t $(c.term)\nCode:\t $(c.code)\nNAME:\t $(c.name)\nSECTION:\t $(c.section)\nSTUDENTS:\n$(c.students)")

end

"""
    Grade

A structure representing a detailed record of a student's grade for a specific assessment in a course.

# Fields
- `student_id::Int`: The unique identifier of the student.
- `student_name::String`: The full name of the student.
- `student_email::String`: The email address of the student.
- `course_id::Int`: The unique identifier of the course.
- `course_code::String`: The code of the course (e.g., `"MATH371"`).
- `course_name::String`: The full name of the course (e.g., `"Introduction to Numerical Computing"`).
- `name::String`: The name of the assessment or assignment (e.g., `"Midterm Exam"`).
- `value::Float64`: The grade received by the student for the assessment.
- `max_value::Float64`: The maximum possible grade for the assessment.

# Example
```julia
grade = Grade(12345, "John Doe", "johndoe@example.com", 1, "MATH371", "Introduction to Numerical Computing", "Final Exam", 90.0, 100.0)
println(grade.student_name)  # Prints "John Doe"
println(grade.value)         # Prints 90.0

```
"""
struct Grade
    student_id::Int
    student_name::String
    student_email::String
    course_id::Int
    course_code::String
    course_name::String
    name::String
    value::Float64
    max_value::Float64
end
Base.show(io::IO, g::Grade) = print(io, "Student ID:\t\t $(g.student_id)\nCourse Name:\t\t $(g.course_code) | $(g.course_name)\nGrade Name:\t\t $(g.name)\nGrade Value:\t\t $(g.value) (/$(g.max_value))")
Base.show(io::IO, gs::Vector{Grade}) = begin
    if length(gs) == 0
        print(io, "No grades ...")
    else
        sids = map(x -> x.student_id, gs)
        snames = map(x -> x.student_name, gs)
        cids = map(x -> x.course_id, gs)
        cnames = map(x -> "$(x.course_code) | $(x.course_name)", gs)
        names = map(x -> x.name, gs)
        values = map(x -> x.value, gs)
        max_vals = map(x -> x.max_value, gs)
        T = stack([sids, snames, cids, cnames, names, values])
        pretty_table(io, T;
            header=(["Student ID", "Student Name", "Course ID", "Course Name", "Grade", "Value"],
                ["", "", "", "", "", "out of $(max_vals[1])"]),
            alignment=[:c, :l, :l, :l, :l, :l])
    end
end
"""
    Result

A structure used to represent the outcome of an operation, which can include data and a corresponding message.

# Fields
- `data::Union{Nothing, Vector{Student}, Vector{Grade}, DataFrame}`: The result of an operation. This field can contain:
    - `Nothing`: If no data is available or the operation failed.
    - `Vector{Student}`: A list of `Student` objects, typically representing enrolled students.
    - `Vector{Grade}`: A list of `Grade` objects, typically representing grades assigned to students.
    - `DataFrame`: A `DataFrame` containing tabular data, such as a dataset from an external source (e.g., a file).
- `message::String`: A descriptive message accompanying the result, which may provide feedback on the operation (e.g., success or error messages).

# Example
```julia
result = Result(Vector{Student}(), "Operation successful")
println(result.message)  # Prints "Operation successful"
println(result.data)     # Prints an empty vector of students
```
"""
struct Result
    data::Union{Nothing,Vector{Student},Vector{Grade},DataFrame}
    message::String
end

export FileData, Student, Course, Grade, Result