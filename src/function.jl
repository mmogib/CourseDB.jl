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
    CourseWithStudents(course_with_id.id, course, students)
end

function addStudents(c::Course, file_path::String, args...; fields::Dict{Symbol,Any}=Dict(:id => "id", :name => "name", :email => "email"), kwargs...)
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
    course_students = save_students(students, course_with_id)

    CourseWithStudents(course_with_id.id, c, course_students)
end


# Course(name::String, term::String, section::String, students_file::String, args...; mapping::Union{Dict{Symbol,String},Dict{Symbol,Any}}=Dict(:id => "id", :name => "name", :email => "email"), kwargs...) = begin
#     dfile = readdata(students_file, args...; kwargs...)
#     df = dfile.data
#     df = dropmissing(df)
#     ids = isa(mapping[:name], Tuple) ? map(x -> isa(x, Int) ? x : parse(Int, x), df[!, mapping[:id][1]]) : map(x -> isa(x, Int) ? x : parse(Int, x), df[!, mapping[:id]])
#     names = isa(mapping[:name], Tuple) ? mapping[:name][2].(df[!, mapping[:name][1]]) : df[!, mapping[:name]]
#     emails = isa(mapping[:email], Tuple) ? mapping[:email][2].(df[!, mapping[:email][1]]) : df[!, mapping[:email]]
#     students_df = DataFrame(id=ids, name=names, email=emails)
#     course_students = save_students(students_df, name, term, section)
#     course_Students = map(r -> Student(r[:id], r[:name], r[:email]), eachrow(course_students))
#     Course(name, term, section, course_Students)
# end
# Course(name::String, term::String, section::String) = begin
#     course_df = get_course(name, term, section)
#     course_students = get_course_students(course_df[!, :id][1])
#     course_Students = map(r -> Student(r[:id], r[:name], r[:email]), eachrow(course_students))
#     Course(name, term, section, course_Students)
# end
# Student(id::Int) = begin
#     student_df = get_student(id)
#     @assert nrow(student_df) > 0 "No student with id. Please check the student id"
#     Student(id, student_df[!, :name][1], student_df[!, :email][1])
# end



# Grade(course_name::String, term::String, section::String, grade_name::String, file_name::String, args...; mapping::Union{Dict{Symbol,String},Dict{Symbol,Any}}=Dict(:student_id => "id", :value => "value", :max_value => "max_value"), kwargs...) = begin
#     course_id = get_course(course_name, term, section)
#     dfile = readdata(file_name, args...; kwargs...)
#     df = dropmissing(dfile.data)
#     trans_fns = Dict(map(x -> x => isa(mapping[x], Tuple) ? mapping[x][2] : x -> x, [:student_id, :value, :max_value]))
#     ids = isa(mapping[:student_id], Tuple) ? df[!, mapping[:student_id][1]] : df[!, mapping[:student_id]]
#     ids = map(x -> isa(x, Int) ? x : parse(Int, x), ids)
#     ids = trans_fns[:student_id].(ids)
#     values = isa(mapping[:value], Tuple) ? df[!, mapping[:value][1]] : df[!, mapping[:value]]
#     values = map(x -> isa(x, AbstractFloat) ? x : parse(Float64, x), values)
#     values = trans_fns[:value].(values)
#     max_values = isa(mapping[:max_value], Tuple) ? df[!, mapping[:max_value][1]] : df[!, mapping[:max_value]]
#     max_values = map(x -> isa(x, AbstractFloat) ? x : parse(Float64, x), max_values)
#     max_values = trans_fns[:max_value].(max_values)
#     grades = map(i -> Grade(ids[i], course_id[!, :id][1], grade_name, values[i], max_values[i]), 1:length(ids))
#     add_student_grades(grades)
#     db_scores = get_scores(grade_name)
#     println(db_scores)
#     grades
# end

export readdata, createCourse, addStudents