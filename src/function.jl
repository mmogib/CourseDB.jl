function readdata(filepath::String, args...; kwargs...)::FileData
    @assert isfile(filepath) "The file $filepath does not exist."
    kind = basename(filepath) |> d -> split(d, ".") |> d -> d[end]
    @assert kind in ["csv", "txt", "xlsx"] "The file extension $kind is not supported."
    data = if kind in ["csv", "txt"]
        CSV.File(filepath; kwargs...) |> DataFrame
    else
        XLSX.readtable(filepath, args...; kwargs...) |> DataFrame
    end

    fields = map(names(data)) do x
        val = typeof(x) <: Real ? "number" : "string"
        x => val
    end |> Dict

    FileData(filepath, fields, data)
end

function createCourse(term::Union{Integer,String}, code::String, name::String, section::Union{Integer,String})
    course = Course(term, code, name, section)
    course_with_id = db_course(course)
    students = get_course_students(course_with_id.id)
    Course(course_with_id, students)
end

function addStudents(c::Course, file_path::String, args...; fields::Union{Dict{Symbol,String},Dict{Symbol,Any}}=Dict(:id => "id", :name => "name", :email => "email"), kwargs...)
    dfile = readdata(file_path, args...; kwargs...)
    df = dfile.data |> dropmissing
    ids = if isa(fields[:id], Tuple)
        tids = map(x -> isa(x, Int) ? x : parse(Int, x), df[!, fields[:id][1]])
        map(fields[:id][2], tids)
    else
        map(x -> isa(x, Int) ? x : parse(Int, x), df[!, fields[:id]])
    end
    names = if isa(fields[:name], Tuple)
        fields[:name][2].(df[!, fields[:name][1]])
    else
        df[!, fields[:name]]
    end
    emails = if isa(fields[:email], Tuple)
        fields[:email][2].(df[!, fields[:email][1]])
    else
        df[!, fields[:email]]
    end
    course_with_id = db_course(c)
    students = map(i -> Student(ids[i], names[i], emails[i]), 1:length(ids))
    course = Course(course_with_id, students)
    course_students = save_students(course)

    Course(course, course_students)
end
function ids(c::Course)
    students = c.students
    if length(students) > 0
        map(x -> x.id, students)
    else
        []
    end
end

function names(c::Course)
    students = c.students
    if length(students) > 0
        map(x -> x.name, students)
    else
        []
    end
end

function emails(c::Course)
    students = c.students
    if length(students) > 0
        map(x -> x.email, students)
    else
        []
    end
end

function addGrades(c::Course, file_path::String, args...;
    fields::Union{Dict{Symbol,String},Dict{Symbol,Any}}=Dict(:sid => "sid", :name => "name", :value => "value", :max_value => "max_value"), kwargs...)
    dfile = readdata(file_path, args...; kwargs...)
    df = dfile.data |> dropmissing
    gids = if isa(fields[:sid], Tuple)
        tids = map(x -> isa(x, Int) ? x : parse(Int, x), df[!, fields[:sid][1]])
        map(fields[:sid][2], tids)
    else
        map(x -> isa(x, Int) ? x : parse(Int, x), df[!, fields[:sid]])
    end
    names = if isa(fields[:name], Tuple)
        fields[:name][2].(df[!, fields[:name][1]])
    else
        df[!, fields[:name]]
    end
    values = if isa(fields[:value], Tuple)
        fields[:value][2].(df[!, fields[:value][1]])
    else
        df[!, fields[:value]]
    end
    max_values = if isa(fields[:max_value], Tuple)
        fields[:max_value][2].(df[!, fields[:max_value][1]])
    else
        df[!, fields[:max_value]]
    end

    course_with_id = db_course(c)
    students = get_course_students(course_with_id.id)
    course = Course(course_with_id, students)
    students_ids = ids(course)
    grades = map(i -> Grade(gids[i], course_with_id.id, names[i], values[i], max_values[i]), 1:length(gids))
    filtered_grades = filter(x -> x.student_id in students_ids, grades)
    if length(grades) > length(filtered_grades)
        @warn "Some grades cannot be saved. No corresponding students. Maybe you need to add the missing students first."
    end
    add_student_grades(grades)

    Course(course, students)
end

function getGrades(c::Course)
    if c.id == "new"
        nothing
    else
        get_course_grades(c)
    end
end


export readdata, createCourse, addStudents, ids, names, emails, addGrades, getGrades