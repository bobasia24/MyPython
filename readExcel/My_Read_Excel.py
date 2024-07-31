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
    # 判断文件路径是否包含"zip"
    if "zip" in file_path:
        # 如果是zip文件，则打开zip文件
        with zf.ZipFile(file_path) as z:
            # 在zip文件中打开"销售单查询.xlsx"文件
            with z.open("销售单查询.xlsx") as f:
                # 读取Excel文件中的数据，并指定工作表为"判断用"
                data_file = pd.read_excel(f, sheet_name="数据库业务员目标")
    else:
        # 如果不是zip文件，则直接读取Excel文件中的数据，并指定工作表为"汇总运费表"
        data_file = pd.read_excel(file_path, sheet_name="Sheet0")
    # 将数据插入到数据库中的"人工导入202402运费汇总"表中，如果表已存在则替换原有数据，不插入索引，每次插入500行数据 append|replace
    data_file.to_sql('人工导入陈老师测试', con=engine, if_exists='replace', index=False, chunksize=500)
    # 输出"数据插入完成"
    print("数据插入完成")

#replace，append

def connection_database():
    # 连接数据库
    port = "3306"
    user = "root"

    # 注释掉的数据库连接信息
    # db_host = "14.116.149.42"
    # password = "Ysyhl9t@"
    # database = "lmykerp_pro"

    # 实际的数据库连接信息
    db_host = "125.91.113.114"
    password = "Report@123"
    database = "profit"

    # 构造连接字符串
    str_format = "mysql+pymysql://{user}:{password}@{db_host}:{port}/{database}?charset=utf8"
    connection_str = str_format.format(user=user, password=parse.quote_plus(password), db_host=db_host, port=port,
                                       database=database)

    # 返回创建的数据库引擎
    return create_engine(connection_str, echo=False)

#test
# 读取
engine = connection_database()
# window
download_file_path = r"C:\Users\73769\Desktop\7月开票深圳市榴芒一刻食品有限公司_销货明细导出文件_.xlsx"
# mac
# download_file_path = r"/Users/liyazhou/Desktop/公司桌面/2024年02月深圳销售明细.xlsx"
file_dispose(download_file_path, engine)


