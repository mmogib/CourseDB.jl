### Course
function db_course(c::Course)
    db = getdb()
    DBInterface.execute(db, "insert or ignore into courses (term,code,name,section) values (?,?,?,?)", [c.term, c.code, c.name, c.section])
    df = DBInterface.execute(db, "select * from courses where term=? and code=? and name=? and section=?", [c.term, c.code, c.name, c.section]) |> DataFrame
    SQLite.close(db)
    Course(c, df[!, :id][1])
end


function get_course(id::Int; with_students::Bool=false)
    db = getdb()
    df = DBInterface.execute(db, "select * from courses where id=?", [id]) |> DataFrame
    SQLite.close(db)
    students = if with_students
        get_course_students(id)
    else
        []
    end
    Course(id, df[!, :term], df[!, :code][1], df[!, :name][1], df[!, :section][1], students)
end

function add_students(students::Vector{Student})
    db = getdb()
    values = join(map(x -> "($(x.id),'$(x.name)','$(x.email)')", students), ",")
    DBInterface.execute(db, "insert or ignore into students (id,name,email) values $values")
    SQLite.close(db)
    students
end

function add_student_courses(c::Course)
    students = c.students
    values = join(map(x -> "($(x.id),$(c.id))", students), ",")
    db = getdb()
    sql = "insert or ignore into student_courses (student_id,course_id) values $values;"
    DBInterface.execute(db, sql)
    SQLite.close(db)
    students
end

function add_student_grades(gs::Vector{Grade})
    values = join(map(x -> "($(x.student_id),$(x.course_id),'$(x.name)',$(x.value),$(x.max_value))", gs), ",")
    db = getdb()
    sql = "insert or ignore into student_grades (student_id,course_id,grade_name,grade_value,grade_max) values $values;"
    DBInterface.execute(db, sql)
    SQLite.close(db)
end

function save_students(c::Course)
    students = c.students
    add_students(students)
    add_student_courses(c)
    get_course_students(c.id)
end

function get_student(id::Int)
    db = getdb()
    df = DBInterface.execute(db, "select * from students where id=?", [id]) |> DataFrame
    SQLite.close(db)
    Student(id, df[!, :name][1], df[!, :email][1])
end

function get_student(ids::Vector{Int})
    in_close = join(ids, ",")
    db = getdb()
    df = DBInterface.execute(db, "select * from students where id in ($in_close)") |> DataFrame
    SQLite.close(db)
    map(x -> Student(x[:id], x[:name], x[:email]), eachrow(df))
end

function get_course_students(course_id::Int)
    db = getdb()
    sql = """
        select 
            t1.* 
        from 
            students t1
        inner join 
            student_courses t2 on t1.id=t2.student_id
        where 
            t2.course_id=?
    """
    df = DBInterface.execute(db, sql, [course_id]) |> DataFrame
    SQLite.close(db)
    map(x -> Student(x[:id], x[:name], x[:email]), eachrow(df))
end

function get_course_grades(c::Course)
    db = getdb()
    sql = """
        select 
            * 
        from 
            student_grades
        where 
            course_id=?
    """
    df = DBInterface.execute(db, sql, [c.id]) |> DataFrame
    SQLite.close(db)
    students = get_course_students(c.id)
    f(id, fld) = begin
        s = filter(y -> y.id == id, students)[1]
        s[fld]
    end
    map(x -> Grade(
            x[:student_id],
            f(x[:student_id], :name),
            f(x[:student_id], :email),
            c.id,
            c.code,
            c.name,
            x[:grade_name],
            x[:grade_value],
            x[:grade_max]),
        eachrow(df))
end

function get_course_grades(c::Course, grade_name::String)
    db = getdb()
    sql = """
        select 
            * 
        from 
            student_grades
        where 
            course_id=? and grade_name='?'
    """
    df = DBInterface.execute(db, sql, [c.id, grade_name]) |> DataFrame
    SQLite.close(db)
    students = get_course_students(c.id)
    f(id, fld) = begin
        s = filter(y -> y.id == id, students)[1]
        s[fld]
    end
    map(x -> Grade(
            x[:student_id],
            f(x[:student_id], :name),
            f(x[:student_id], :email),
            c.id,
            c.code,
            c.name,
            x[:grade_name],
            x[:grade_value],
            x[:grade_max]),
        eachrow(df))
end


function reset_db()
    db = getdb(true)
    SQLite.close(db)
end

function getdb(reset_db=false)
    dbpath = "database/courses.db"
    mkpath(dirname(dbpath))
    db = SQLite.DB(dbpath)
    if reset_db
        foreach(["student_courses", "student_grades", "students", "courses"]) do table
            DBInterface.execute(db, "DROP TABLE IF EXISTS $table;")
        end
    end

    # SQL statement to create the students table (if not already created)
    create_students_table_sql = """
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL
    );
    """
    # Execute the SQL statement
    DBInterface.execute(db, create_students_table_sql)
    creat_courses_table_sql = """
     CREATE TABLE IF NOT EXISTS courses (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         term TEXT NOT NULL,
         code TEXT NOT NULL,
         name TEXT NOT NULL,
         section TEXT NOT NULL,
         UNIQUE(term, code, section)
     );
     """
    DBInterface.execute(db, creat_courses_table_sql)
    creat_reg_table_sql = """
     CREATE TABLE IF NOT EXISTS student_courses (
         student_id INTEGER NOT NULL,
         course_id INTEGER NOT NULL,
         UNIQUE(student_id,course_id)
     );
     """
    DBInterface.execute(db, creat_reg_table_sql)
    create_scores_table_sql = """
    CREATE TABLE IF NOT EXISTS student_grades (
        student_id INTEGER,
        course_id INTEGER,
        grade_name TEXT,
        grade_value REAL,
        grade_max REAL,
        PRIMARY KEY(student_id,course_id,grade_name)
    );
    """
    # Execute the SQL statement
    DBInterface.execute(db, create_scores_table_sql)
    db
end


export reset_db