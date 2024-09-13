function save_students(students::DataFrame, course::String, term::String, section::String)
    db = getdb()
    sql_statemnt = "select * from students where course_id='$(term)$(course)$(section)';"
    df = DBInterface.execute(db, sql_statemnt) |> DataFrame
    new_students = if nrow(df) == 0
        students
    else
        antijoin(students, df, on=:id)
    end
    SQLite.load!(new_students, db, "students")
    df = DBInterface.execute(db, sql_statemnt) |> DataFrame

    SQLite.close(db)
    df
end

function reset_db()
    db = getdb(true)
    SQLite.close(db)
end

function get_student(id::Int)
    db = getdb()
    df = DBInterface.execute(db, "select * from students t1 inner join courses t2 on t1.course_id=concat(t2.term,t2.course,t2.section) where t1.id=?", [id]) |> DataFrame
    SQLite.close(db)
    df
end


function get_course(id::String)
    db = getdb()
    df = DBInterface.execute(db, "select * from students t1 inner join courses t2 on t1.course_id=concat(t2.term,t2.course,t2.section) where concat(t2.term,t2.course,t2.section)=?", [id]) |> DataFrame
    SQLite.close(db)
    df
end


function add_course(course::String, term::String, section::String)
    db = getdb()
    sql_statemnt = "select * from courses where term='$term' and course='$course' and section='$section';"
    df = DBInterface.execute(db, sql_statemnt) |> DataFrame
    course_df = if nrow(df) > 0
        df
    else
        DBInterface.execute(db, "insert into courses (course,term,section) values (?,?,?)", [course, term, section])
        df = DBInterface.execute(db, sql_statemnt) |> DataFrame
        df
    end
    SQLite.close(db)
    course_df
end
# function load_students()
#     db = getdb()
#     df = DBInterface.execute(db, "select * from students;") |> DataFrame
#     SQLite.close(db)
#     df
# end

# function load_students(file_name::String; new_course::Bool=false)
#     new_course == true && @assert isfile(file_name) "The file name provided $file_name doe not exist."
#     db = getdb()
#     df0 = DBInterface.execute(db, "select * from students;") |> DataFrame
#     df = if nrow(df0) > 0
#         load_students(df)
#         df
#     else
#     end
#     SQLite.close(db)
#     df
# end

function savescores(grade_name::String, filename::String)
    df = get_scores(grade_name)
    savecsv(df, filename)
    df
end


function get_scores(grade_name)
    db = getdb()
    df = DBInterface.execute(db, "select t1.*,t2.name,t2.section from student_scores t1 inner join students t2 on t1.student_id=t2.id where grade_name='$grade_name' order by t2.section, t2.id;") |> DataFrame
    SQLite.close(db)
    df
end

function getdb(reset_db=false)
    dbpath = "database/courses.db"
    mkpath(dirname(dbpath))
    db = SQLite.DB(dbpath)

    # SQL statement to create the students table (if not already created)
    create_students_table_sql = """
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        course_id Text,
        PRIMARY KEY (id, course_id)
    );
    """
    # Execute the SQL statement
    SQLite.execute(db, create_students_table_sql)
    creat_courses_table_sql = """
     CREATE TABLE IF NOT EXISTS courses (
         term TEXT,
         course TEXT,
         section TEXT,
         PRIMARY KEY (term, course, section)
     );
     """
    SQLite.execute(db, creat_courses_table_sql)
    create_scores_table_sql = """
    CREATE TABLE IF NOT EXISTS student_grades (
        student_id INTEGER,
        course_id TEXT,
        grade_name TEXT,
        grade_value REAL,
        grade_max REAL,
        PRIMARY KEY (student_id, course_id, grade_name),
        FOREIGN KEY (student_id) REFERENCES students(id)
    );
    """
    # Execute the SQL statement
    SQLite.execute(db, create_scores_table_sql)
    reset_db && SQLite.execute(db, "DELETE FROM student_grades;DELETE FROM students;DELETE FROM courses;")
    db
end

function savecsv(df::DataFrame, filename::String; args...)
    folder = dirname(filename)
    file_base = basename(filename)
    file_path = mkpath(folder)
    CSV.write("$file_path/$file_base", eachrow(df); args...)
end


export reset_db