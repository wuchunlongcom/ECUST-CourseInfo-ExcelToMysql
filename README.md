```
华东理工大学课程信息表，使用了mysql数据库。
1、实现从excel数据批量初始化到mysql数据库。
2、通过后台admin提交数据到mysql数据库。

打开终端 --> 点击右边的【终端】；再打开终端 -->【commmond】【T】

快速 进入py375  
$ source  /Users/wuchunlong/local/env375/bin/activate
快速 进入工程目录(/Users/wuchunlong/local/github/ECUST-CourseInfo-Mysql)
$ cd /Users/wuchunlong/local/github/ECUST-CourseInfo-Mysql
创建mysql数据库和表
(env375) wuchunlongdeMacBook-Pro:courseinfo wuchunlong$ ./create_mysql.sh
运行
(env375) wuchunlongdeMacBook-Pro:courseinfo wuchunlong$ ./start.sh
```

### 技术要点
```
创建mysql数据库和表脚本
create_mysql.sh
function create_db {
    logging "mystudb "

    HOSTNAME="127.0.0.1" #数据库信息
    PORT="3306"
    USERNAME="root"
    PASSWORD="12345678"
    DBNAME="mystudb"  # 数据库名称

    # 删除数据库
    delete_sql="drop database ${DBNAME}"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${delete_sql}"
    # 创建数据库
    create_db_sql="create database IF NOT EXISTS ${DBNAME}"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"

    
    # 自动创建表account_student、auth_group ...
    logging "makemigrations" 
    python "manage.py" "makemigrations" 

    logging "migrate"
    python "manage.py" "migrate"

}

settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'mystudb',        #数据库名字 mystudb
        'USER': 'root',          #账号
        'PASSWORD': '12345678',      #密码
        'HOST': '127.0.0.1',    #IP
        'PORT': '3306',         #端口
    }
}
 
```

### mysql 常用命令
```
$ mysql -u root -p
mysql> create database studb;  # 创建数据库 一定要有分号；！
mysql> show databases;  # 显示数据库
mysql> use mystudb;   # 使用数据库studb   必须！！！
mysql> show tables;  # 显示表
mysql>select * from account_student;  # 显示表数据
mysql> drop database studb; # 删除数据库studb
mysql> quit # 退出

```

### 验证mysql获得数据
```
Django version 2.2.6, using settings 'courseinfo.settings-debug'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.

(env375) wuchunlongdeMacBook-Pro:courseinfo wuchunlong$ mysql -u root -p
Enter password: 12345678
...
mysql>show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysqldb            |
| mystudb            |
| performance_schema |
| studb              |
| sys                |
| test_db_test       |
+--------------------+
8 rows in set (0.00 sec) 
mysql> use mystudb;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------------+
| Tables_in_mystudb          |
+----------------------------+
| auth_group                 |
| auth_group_permissions     |
| auth_permission            |
| auth_user                  |
| auth_user_groups           |
| auth_user_user_permissions |
| classroom_building         |
| classroom_campus           |
| classroom_classroom        |
| classroom_classroomtype    |
| classroom_course           |
| classroom_teacher          |
| classroom_term             |
| django_admin_log           |
| django_content_type        |
| django_migrations          |
| django_session             |
+----------------------------+
17 rows in set (0.00 sec)

mysql> select * from classroom_campus;
+--------------+---------------+----------------+
| name         | show_schedule | show_classroom |
+--------------+---------------+----------------+
| 奉贤校区     |             1 |              1 |
| 徐汇校区     |             1 |              1 |
| 金山校区     |             1 |              1 |
+--------------+---------------+----------------+
3 rows in set (0.00 sec)

mysql> quit

通过后台admin增加 浦东校区 http://localhost:8000/admin/classroom/campus/
    金山校区        
    浦东校区        
    徐汇校区        
    奉贤校区
    
mysql> use mystudb;

mysql> select * from classroom_campus;
+--------------+---------------+----------------+
| name         | show_schedule | show_classroom |
+--------------+---------------+----------------+
| 奉贤校区     |             1 |              1 |
| 徐汇校区     |             1 |              1 |
| 浦东校区     |             1 |              1 |
| 金山校区     |             1 |              1 |
+--------------+---------------+----------------+
4 rows in set (0.00 sec)
    
            
```

### 来源文相 https://github.com/wu-wenxiang/Project-ECUST-CourseInfo

### 修改了源码 
```  
1、将 raise Http404("Term does not exist")  改为 return '','',''
def _getDateInfo(date):      
    terms = [i for i in Term.objects.all() if i.start <= date <= i.end]    
    if not terms:
        return '','',''  # add 增加此语句
        raise Http404("Term does not exist")    
    term = terms[0]    
    isocalendar = date.isocalendar()
    week = (date - term.firstMonday).days // 7 + 1
    weekday = isocalendar[2]
    #print(date, "-->", term.name, week, weekday) #2020-10-08 --> 2020-2021-1 6 4  (2020/10/8 -- 第 6 周 -- 星期 4 
    return term.name, week, weekday
否则下列两个函数出错！
def classroomInfo(request, campus, building):   
def classroomDetails(request, campus, building, classroom):

2、为什么将  ../data/syncdb.py 更名为   sync_db.py ？
因为syncdb.py文件名不能上传到git,不知是什么原因？

3、excel字段实际长度>16,导致写入数据时出错。故改为128
class Classroom(models.Model):
    id = models.CharField(verbose_name='教室ID', max_length=128, primary_key=True, blank=True) #16

2021.09.26
```
