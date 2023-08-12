#! /usr/bin/env python
# -*- coding:utf-8 -*-
# __author__ = "wzp"
import warnings
import zipfile as zf
from urllib import parse

import pandas as pd
from sqlalchemy import create_engine

# 解决warning: UserWarning: Workbook contains no default style, apply openpyxl's default
warnings.simplefilter('ignore')


def file_dispose(file_path, engine):
    """获取文件"""
    # if path2.count("zip") > 0:
    if "zip" in file_path:
        with zf.ZipFile(file_path) as z:
            with z.open("销售单查询.xlsx") as f:
                data_file = pd.read_excel(f, sheet_name="sheetTitle0")
    else:
        data_file = pd.read_excel(file_path, sheet_name="Sheet1")
    data_file.to_sql('运费7月更新1', con=engine, if_exists='replace', index=False, chunksize=500)
    print("数据插入完成")


def connection_database():
    # 连接数据库
    db_host = "14.116.149.42"
    port = "3306"
    user = "root"
    password = "Ysyhl9t@"
    database = "lmykerp"
    str_format = "mysql+pymysql://{user}:{password}@{db_host}:{port}/{database}?charset=utf8"
    connection_str = str_format.format(user=user, password=parse.quote_plus(password), db_host=db_host, port=port,
                                       database=database)
    return create_engine(connection_str, echo=False)

# 读取
engine = connection_database()
download_file_path = r"C:\Users\73769\Desktop\运费7月更新.xlsx"
file_dispose(download_file_path, engine)