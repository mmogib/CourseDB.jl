struct FileData
    path::String
    fields::Dict{String,String}
    data::DataFrame
end

struct Student
    id::Int
    name::String
    email::String
end

struct Course
    term::String
    code::String
    name::String
    section::String
    function Course(t::String, c::String, name::String, sec::String)
        code = replace(c, " " => "") |> uppercase
        new(t, code, name, sec)
    end
    function Course(t::Integer, c::String, name::String, sec::Integer)
        code = replace(c, " " => "") |> uppercase
        new("$t", code, name, "$sec")
    end
    function Course(t::Integer, c::String, name::String, sec::String)
        code = replace(c, " " => "") |> uppercase
        new("$t", code, name, sec)
    end
    function Course(t::String, c::String, name::String, sec::Integer)
        code = replace(c, " " => "") |> uppercase
        new(t, code, name, "$sec")
    end
end
struct CourseWithID
    id::Int
    course::Course
end

struct CourseWithStudents
    course_id::Int
    course::Course
    students::Vector{Student}
end

struct Grade
    student_id::Int
    course_id::Int
    name::String
    value::Float64
    max_value::Float64
end


export FileData, FileData, Student, Grade, Course, CourseWithID, CourseWithStudents