import requests
import re
import xlwt  # excel操作
import time
# 爬虫双色球并导入excel
global all_page
url = "http://kaijiang.zhcw.com/zhcw/html/ssq/list_1.html"
reponse = requests.get(url=url)
reponse.encoding = 'utf-8'
html = reponse.text
# all_page = int(re.findall(r"class=\"pg\".*?<strong>(.*?)</strong>", html)[0])  # 获取的总页数
all_page = int(15)
# 组建excel
k = -1
f = xlwt.Workbook(encoding='utf-8')
sheet01 = f.add_sheet(u'sheel1', cell_overwrite_ok=True)
for page_num in range(1, all_page):
    url = "http://kaijiang.zhcw.com/zhcw/html/ssq/list_" + str(page_num) + ".html"
    reponse = requests.get(url=url)
    time.sleep(5)
    reponse.encoding = 'utf-8'
    html = reponse.text
    rule = r"<tr>.*?<td align=\"center\">(.*?)</td>.*?<td align=\"center\">(.*?)</td>.*?<td align=\"center\" style=\"padding-left:10px;\">.*?<em class=\"rr\">(.*?)</em>.*?<em class=\"rr\">(.*?)</em>.*?<em class=\"rr\">(.*?)</em>.*?<em class=\"rr\">(.*?)</em>.*?<em class=\"rr\">(.*?)</em>.*?<em class=\"rr\">(.*?)</em>.*?<em>(.*?)</em></td>"
    num = re.findall(rule, html, re.S | re.M)
    # f = xlwt.Workbook(encoding='utf-8')
    # sheet01 = f.add_sheet(u'sheel1', cell_overwrite_ok=True)
    sheet01.write(0, 0, "日期")
    sheet01.write(0, 1, "期数")
    sheet01.write(0, 2, "第一个红球")
    sheet01.write(0, 3, "第二个红球")
    sheet01.write(0, 4, "第三个红球")
    sheet01.write(0, 5, "第四个红球")
    sheet01.write(0, 6, "第五个红球")
    sheet01.write(0, 7, "第六个红球")
    sheet01.write(0, 8, "蓝球")
    print("正在写入第%s页" % (page_num))
    for i in range(0, len(num)):
        k += 1
        sheet01.write(k + 1, 0, num[i][0])
        sheet01.write(k + 1, 1, num[i][1])
        sheet01.write(k + 1, 2, num[i][2])
        sheet01.write(k + 1, 3, num[i][3])
        sheet01.write(k + 1, 4, num[i][4])
        sheet01.write(k + 1, 5, num[i][5])
        sheet01.write(k + 1, 6, num[i][6])
        sheet01.write(k + 1, 7, num[i][7])
        sheet01.write(k + 1, 8, num[i][8])

f.save("双色球统计结果.csv")