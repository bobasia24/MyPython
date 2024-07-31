from lunardate import LunarDate
from datetime import datetime, timedelta
from openpyxl import Workbook
from openpyxl.styles import Alignment


def convert_to_lunar(year, month, day):
    # 将公历日期转换为农历日期
    lunar_date = LunarDate.fromSolarDate(year, month, day)
    return lunar_date


def format_lunar_date(lunar_date):
    # 格式化农历日期为 'YYYY-MM-DD' 格式
    return f"{lunar_date.year}-{lunar_date.month:02d}-{lunar_date.day:02d}"


def main():
    # 创建一个新的Excel工作簿
    wb = Workbook()
    ws = wb.active
    ws.title = "农历日期"

    # 设置表头
    ws.append(["公历日期", "农历日期"])

    # 遍历2020年1月1日到2030年12月31日之间的日期
    start_date = datetime(2020, 1, 1)
    end_date = datetime(2030, 12, 31)
    delta = timedelta(days=1)

    current_date = start_date
    while current_date <= end_date:
        gregorian_date = current_date.date()
        year = gregorian_date.year
        month = gregorian_date.month
        day = gregorian_date.day

        # 转换为农历日期
        lunar_date = convert_to_lunar(year, month, day)

        # 格式化农历日期为 'YYYY-MM-DD' 格式
        formatted_lunar_date = format_lunar_date(lunar_date)

        # 写入Excel表格
        ws.append([gregorian_date, formatted_lunar_date])

        # 移动到下一天
        current_date += delta

    # 调整列宽和居中显示
    for col in ws.columns:
        max_length = 0
        for cell in col:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(cell.value)
            except:
                pass
        adjusted_width = (max_length + 2) * 1.2
        ws.column_dimensions[col[0].column_letter].width = adjusted_width
        for cell in col:
            cell.alignment = Alignment(horizontal='center', vertical='center')

    # 保存Excel文件
    wb.save("lunar_dates.xlsx")
    print("Excel文件已保存成功！")


if __name__ == "__main__":
    main()
