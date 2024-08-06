with
aa1 as (
select date_format(`订货日期（阳历）`,'%Y-%m-%d') as 农历日期,date_format(`订货日期（阳历）`,'%Y-%m') 年月 ,数量, 销售, 店铺,规格,
case
	when 店铺 regexp '-dg' then '东莞'
	when cc1.平台 is null and cc2.管理报表渠道名称 is not null then cc2.管理报表渠道名称
 	when cc1.平台 is null and cc2.管理报表渠道名称 is  null then  substring_index(店铺,'-sz',1)
else cc1.平台 end 平台
from profit.人工导入月饼历史数据 bb1
left join (select * from profit.人工导入自营店铺平台分类 group by 渠道)cc1 on bb1.店铺 = cc1.渠道
left join (select * from profit.dm_01财务_profit_客户中间表 group by 渠道) cc2 on bb1.店铺 = cc2.渠道
where bb1.`订货日期（阳历）` regexp '2023|2022'
)
,a as (select 农历日期,left(农历日期,7) 年月,sum(数量) 总销量,销售,销售渠道,大小盒,管理报表渠道名称
from  profit.dw_吉客云销售明细单_月饼下单
where 农历日期 regexp '2024'
group by 大小盒,农历日期,管理报表渠道名称
order by 销售,农历日期 asc)
,b as (select * from profit.人工导入自营店铺平台分类 group by 渠道)
,c as (select 农历日期,年月,总销量,销售,销售渠道,大小盒,管理报表渠道名称,
		case when a.销售渠道 regexp '-dg' then '东莞'
	  		when b.平台 is null then a.管理报表渠道名称 else b.平台 end 平台
from a  left join b on a.销售渠道 = b.渠道)

-- 拼接历史数据
,d as (select 销售,农历日期,大小盒,平台,sum(总销量)销量  from c
group by 销售,农历日期,大小盒,平台
union  all
select 销售,农历日期,规格,平台,sum(数量)销量  from aa1
group by 销售,农历日期,规格,平台)



select  date_format(农历日期,'%m-%d')月份,大小盒,平台,销售,
sum(case when 农历日期 regexp '2022' then 销量  end) 销量_2022,
sum(case when 农历日期 regexp '2023' then 销量  end) 销量_2023,
sum(case when 农历日期 regexp '2024' then 销量  end) 销量_2024
from d where 农历日期 regexp '-05-|-06-|-07-|-08-|-09-|-10-'
-- and 大小盒 = '大盒' and 平台 = '拼多多' and 销售 = '销售'
${if(len(dxh1)=0,"","and 大小盒 in('"+dxh1+"')")}
${if(len(pt)=0,"","and 平台 in('"+pt+"')")}
${if(len(xs)=0,"","and 销售 in('"+xs+"')")}
group by 月份
-- ,大小盒,销售,平台
  ${if(len(dxh1)=0,""," ,大小盒 ")}
  ${if(len(pt)=0,""," ,平台 ")}
  ${if(len(xs)=0,""," ,销售 ")}
order by 月份 asc




