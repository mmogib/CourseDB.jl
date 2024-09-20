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

struct Grade
    student_id::Int
    course_id::Int
    name::String
    value::Float64
    max_value::Float64
end
Base.show(io::IO, g::Grade) = print(io, "Student ID:\t\t $(g.student_id)\nCourse ID:\t\t $(g.course_id)\nGrade Name:\t\t $(g.name)\nGrade Value:\t\t $(g.value) (/$(g.max_value))")
Base.show(io::IO, gs::Vector{Grade}) = begin
    if length(gs) == 0
        print(io, "No grades ...")
    else
        sids = map(x -> x.student_id, gs)
        cids = map(x -> x.course_id, gs)
        names = map(x -> x.name, gs)
        values = map(x -> x.value, gs)
        max_vals = map(x -> x.max_value, gs)
        T = stack([sids, cids, names, values])
        pretty_table(io, T; header=(["Student ID", "Course ID", "Grade", "Value"], ["", "", "", "out of $(max_vals[1])"]), alignment=[:c, :l, :l, :l])
    end
end

export FileData, Student, Course, Grade