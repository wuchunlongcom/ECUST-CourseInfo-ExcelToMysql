#!/usr/bin/env bash

pushd `dirname $0` > /dev/null
BASE_DIR=`pwd -P`
popd > /dev/null

#############
# Functions
#############
function logging {
    echo "[INFO] $*"
}
function build_venv {
    # if [ ! -d env ]; then
    #     virtualenv env
    # fi
    # . env/bin/activate
    pip3 install -r requirements.txt

}


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


#############
# Main
#############
cd ${BASE_DIR}
build_venv

cd ${BASE_DIR}/{courseinfo}
OPT_ENV_FORCE=$1
create_db




