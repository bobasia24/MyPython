
with a as (
-- 指标1
select case
	when 地址 regexp '北京' then '北京市'
	when 地址 regexp '上海' then '上海市'
	when 地址 regexp '天津' then '天津市'
	when 地址 regexp '重庆' then '重庆市'
	when 地址 regexp '黑龙' then '黑龙江省'
	when 地址 regexp '吉林' then '吉林省'
	when 地址 regexp '辽宁' then '辽宁省'
	when 地址 regexp '河北' then '河北省'
	when 地址 regexp '甘肃' then '甘肃省'
	when 地址 regexp '青海' then '青海省'
	when 地址 regexp '陕西' then '陕西省'
	when 地址 regexp '河南' then '河南省'
	when 地址 regexp '山东' then '山东省'
	when 地址 regexp '山西' then '山西省'
	when 地址 regexp '安徽' then '安徽省'
	when 地址 regexp '湖北' then '湖北省'
	when 地址 regexp '湖南' then '湖南省'
	when 地址 regexp '江苏' then '江苏省'
	when 地址 regexp '川' then '四川省'
	when 地址 regexp '贵州' then '贵州省'
	when 地址 regexp '云南' then '云南省'
	when 地址 regexp '浙江' then '浙江省'
	when 地址 regexp '江西' then '江西省'
	when 地址 regexp '广东' then '广东省'
	when 地址 regexp '福建' then '福建省'
	when 地址 regexp '台湾' then '台湾省'
	when 地址 regexp '海南' then '海南省'
	when 地址 regexp '新疆' then '新疆维吾尔自治区'
	when 地址 regexp '内蒙' then '内蒙古自治区'
	when 地址 regexp '宁夏' then '宁夏回族自治区'
	when 地址 regexp '广西' then '广西壮族自治区'
	when 地址 regexp '藏' then '西藏自治区'
	when 地址 regexp '香港' then '香港特别行政区'
	else '广东省'
end as 地址,实付金额
from profit.dw_吉客云销售明细单
where 发货时间 like '202%' and 渠道 regexp '京东自营'  and  地址 is not null
)
,b as (select round(sum(ifnull(实付金额,0)),2)  总金额 from a)


select
地址,round(sum(ifnull(实付金额,0)),2) 省总金额, 总金额,sum(实付金额)/总金额 金额占比
from a
left join b on 1=1
group by 地址 order by 省总金额 desc