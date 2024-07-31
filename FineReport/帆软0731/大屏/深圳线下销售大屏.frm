<?xml version="1.0" encoding="UTF-8"?>
<Form xmlVersion="20211223" releaseVersion="11.0.0">
<TableDataMap>
<TableData name="月度各区域目标达成率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
left(发货时间,7)发货时间 ,sum(实付金额) 销售额,
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end
区域1   from 
profit.dw_吉客云销售明细单 
where  部门  regexp '线下|分销'  
and left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品|赠品|dg' 
-- and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by left(发货时间,7),区域1
) 
select 发货时间, 区域1 区域
,round(销售额/10000,2) 销售额
,round(目标额/10000,2) 目标额
,销售额/目标额 达成率
from a 
left join profit.人工导入bi线下地区目标 b
on a.区域1  = b.地区 and  a.发货时间 = b.日期
where a.区域1 is not null 
order by 销售额 desc
]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度总销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  
,sum(销量) 销量
from 
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  and 渠道 not regexp '赠品|dg'
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m')  
and 渠道 not regexp '样品' 
and 货品名称 not regexp '贴纸|雨伞|不拆分|补差价']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度渠道冰粽毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end 区域
,季节性产品分类
,round((sum(含税单价*销量))/100,2) 成本
,round((sum(ifnull(实付金额,0)))/100 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/100 ,2)) - (round((sum(含税单价*销量))/100,2)) 毛利
from  
profit.dw_吉客云销售明细单  
where  部门  regexp '线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'  

and 季节性产品分类 regexp '月饼'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 区域,left(发货时间,7),季节性产品分类
)

select 区域,毛利/金额  毛利率 ,季节性产品分类
 from  a  where a.区域 is not null
 group by 区域
 order by 区域 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润
,sum(销量) 销量 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY))  
and 渠道 not regexp '样品|赠品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售贡献榜_合计" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[-- 
-- select * from 
-- (
-- select 
--  case 
--  	when  区域  regexp '分销' then '分销'
--  	else 区域
--  end  区域1,
-- '合计' 类型1
-- 
-- --  ,sum(数量*箱装系数c) 销量
--  ,round(sum(实付金额),2) 金额 
--  from 
-- profit.dw_吉客云销售明细单_下单
-- where   部门  regexp '线下|分销' 
-- and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
-- and 渠道 not regexp '样品' 
-- and 货品名称 regexp '冰粽|冰淇淋' 
-- and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
-- group by 区域1,left(下单时间,7) ,类型1)asd
-- group by 区域1,类型1
-- 
-- union all 
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
case  
when 货品名称 regexp '冰粽' then 	'冰粽销售额' 
when 货品名称 regexp '冰淇淋' then 	'冰淇淋销售额' 
end 类型1

--  ,sum(数量*箱装系数c) 销量
 ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1






]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="年累计销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select round(sum(ifnull(实付金额,0)),2)  总金额
,sum(含税单价*销量) 成本 
,(round(sum(ifnull(实付金额,0)),2)) - (sum(含税单价*销量)) as 利润  
,sum(销量) 销量 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )
and 发货时间 like '2024%'  and 渠道 not regexp '样品|赠品|dg' 
and 货品名称 not regexp '贴纸|雨伞|不拆分|补差价']]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="同比分析" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
with a as (
select round((sum(ifnull(实付金额,0)))/10000,2) as '2024年'
,round(sum(销量 * 含税单价)/10000,2)  成本_2024
,concat(month(发货时间),'月') 月份 from  
profit.dw_吉客云销售明细单  
where  (部门  regexp '线下|分销|市场' or 部门 is null )  
and 渠道 not regexp '样品|赠品|dg' 
and 发货时间 like '2024%'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by left(发货时间,7) 
)

select a.月份,a.2024年,(a.2024年-成本_2024) / a.2024年 利润率,b.2023年 from a join 
(select concat(month(concat(时间,'-01')),'月') 月份
,round(应收金额/10000,2)  '2023年' from 
profit.ods人工导入23年线下) b
on a.月份  = b.月份;]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度渠道冰淇淋毛利率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
case 
	when `区域/组别` regexp '分销' then '分销'
	else `区域/组别`
end 区域
,季节性产品分类
,round((sum(含税单价*销量))/100,2) 成本
,round((sum(ifnull(实付金额,0)))/100 ,2)  金额
,(round((sum(ifnull(实付金额,0)))/100 ,2)) - (round((sum(含税单价*销量))/100,2)) 毛利
from  
profit.dw_吉客云销售明细单  
where  部门  regexp '线下|分销' 
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'  

and 季节性产品分类 regexp '冰淇淋'
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
group by 区域,left(发货时间,7),季节性产品分类
)

select 区域,毛利/金额  毛利率 ,季节性产品分类
 from  a  where a.区域 is not null 
 group by 区域
 order by 区域 ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月度各品类销售额" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select round(sum(ifnull(实付金额,0)),2)  总金额 ,分类 from  
profit.dw_吉客云销售明细单 
where 分类 is not null  and 分类 != '组合'
and   部门  regexp '线下|分销'
and  left(发货时间,7) = date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品'
group by 分类]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售贡献榜_发货时间" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select 
 case 
 	when  管理报表渠道名称  regexp '分销' then '分销'
 	else 管理报表渠道名称
 end  区域1

 ,round(sum(实付金额),2) 销售额 
 from 
profit.dw_吉客云销售明细单
where   部门  regexp '线下|分销|市场' 
and 发货时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品|赠品|dg|小红书' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(发货时间,7)
order by 销售额 DESC]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销量贡献榜" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[
select * from 
(
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
'合计' 类型1

 ,sum(数量*箱装系数c) 销量
--  ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1)asd
group by 区域1,类型1

union all 
select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1,
case  
when 货品名称 regexp '冰粽' then 	'冰粽销量' 
when 货品名称 regexp '冰淇淋' then 	'冰淇淋销量' 
end 类型1

 ,sum(数量*箱装系数c) 销量
--  ,round(sum(实付金额),2) 金额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品' 
and 货品名称 regexp '冰粽|冰淇淋' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7) ,类型1






]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="月维度业务员目标达成率" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
select 
实付金额 ,销售人员,left(发货时间,7) 发货时间,渠道
from  profit.dw_吉客云销售明细单 
where  部门  regexp '线下|分销' 
and  left(发货时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)

,aa as (
select round(sum(实付金额) ,2) 销售额 ,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,发货时间 from a 
group by 发货时间,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end

)



,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,发货时间,渠道 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)

,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,发货时间 from b
group by b.销售人员,b.发货时间)


select 发货时间,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,销售额/目标额 达成率 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.发货时间 = cc.日期
where cc.业务员 is not null 

union all 

select 发货时间,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,销售额/目标额 达成率 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.发货时间 = aaa.日期
where aaa.销售人员 is not null 

order by 销售额 desc ]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="ds1" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
-- 基础数据过滤
select 
实付金额 ,销售人员,left(下单时间,7) 下单时间7,渠道,二级部门
from  profit.dw_吉客云销售明细单_下单 d吉下 
where 一级部门  regexp '深圳线下' 
and  left(下单时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg'  
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)
-- 清洗分销销售人员名称
,aa as (
select round(sum(实付金额) ,2) 销售额 ,二级部门,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,下单时间7 from a 
group by 下单时间7,二级部门,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
)

-- 按渠道匹配业务员
,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,下单时间7,渠道,二级部门 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)
-- 线下业务员 聚合
,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,下单时间7,二级部门 from b
group by b.销售人员,b.下单时间7,二级部门)


select sum(销售额) 销售额,sum(目标额)目标额, 二级部门,下单时间7 from  (
-- 线下业务员目标
select 下单时间7,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,二级部门 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.下单时间7 = cc.日期
where cc.业务员 is not null 

union all 
-- 分销业务员目标
select 下单时间7,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,二级部门 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.下单时间7 = aaa.日期
where aaa.销售人员 is not null 

)k
group by 二级部门]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="ds2" class="com.fr.data.impl.DBTableData">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O>
<![CDATA[]]></O>
</Parameter>
</Parameters>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[with a as (
-- 基础数据过滤
select 
实付金额 ,销售人员,left(下单时间,7) 下单时间7,渠道,二级部门
from  profit.dw_吉客云销售明细单_下单 d吉下 
where 一级部门  regexp '深圳线下' 
and  left(下单时间,7) =  date_format((CURDATE() - INTERVAL 1 DAY),'%Y-%m') 
and 渠道 not regexp '样品|dg'  
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分'
)
-- 清洗分销销售人员名称
,aa as (
select round(sum(实付金额) ,2) 销售额 ,二级部门,
case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
销售人员,下单时间7 from a 
group by 下单时间7,二级部门,case 
	when 销售人员 regexp '钟意珍|陈玉' then '钟意珍_陈玉' else 销售人员
end
)

-- 按渠道匹配业务员
,b as (
select 实付金额,
case when bb.业务员 is not null then  bb.业务员 else  a.销售人员 end  
销售人员,下单时间7,渠道,二级部门 from a  left join
(select * from profit.人工导入bi线下业务员渠道关系 group by 销售渠道) bb
on substring_index(a.渠道,'-sz',1) = bb.销售渠道
where bb.业务员 is not null 
)
-- 线下业务员 聚合
,c as (
select round(sum(实付金额),2) 销售额 ,销售人员,下单时间7,二级部门 from b
group by b.销售人员,b.下单时间7,二级部门)


select sum(销售额) 销售额,sum(目标额)目标额, 二级部门,下单时间7,销售人员 from  (
-- 线下业务员目标
select 下单时间7,销售人员,round(销售额/10000,2)销售额,round(目标额/10000,2) 目标额,二级部门 from c left join 
(select round(目标额,2)目标额,业务员 ,日期 from profit.人工导入bi线下业务员目标) cc
on c.销售人员 = cc.业务员 and c.下单时间7 = cc.日期
where cc.业务员 is not null 

union all 
-- 分销业务员目标
select 下单时间7,aa.销售人员,round(aa.销售额/10000,2) 销售额,round(目标额/10000,2) 目标额,二级部门 from aa 
left join 
(select * from profit.人工导入bi分销业务员目标) aaa
on aa.销售人员 =aaa.销售人员 and  aa.下单时间7 = aaa.日期
where aaa.销售人员 is not null 

)k
where 二级部门 = '${area}' 
group by 销售人员]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
<TableData name="日维度销售贡献榜" class="com.fr.data.impl.DBTableData">
<Parameters/>
<Attributes maxMemRowCount="-1"/>
<Connection class="com.fr.data.impl.NameDatabaseConnection">
<DatabaseName>
<![CDATA[125.91.113.114_mysql]]></DatabaseName>
</Connection>
<Query>
<![CDATA[select 
 case 
 	when  区域  regexp '分销' then '分销'
 	else 区域
 end  区域1
--  ,case  
-- when 货品名称 regexp '冰粽' then 	'冰粽销售额' 
-- when 货品名称 regexp '冰淇淋' then 	'冰淇淋销售额' 
-- end 类型1

--  ,sum(数量*箱装系数c) 销量
 ,round(sum(实付金额),2) 销售额 
 from 
profit.dw_吉客云销售明细单_下单
where   部门  regexp '线下|分销|市场' 
and 下单时间 =  DATE(DATE_SUB(CURDATE(), INTERVAL 1 DAY)) 
and 渠道 not regexp '样品|赠品|dg' 
and 货品名称 not regexp '贴纸|雨伞|补差价|不拆分|预付卡'
group by 区域1,left(下单时间,7)
order by 销售额 DESC]]></Query>
<PageQuery>
<![CDATA[]]></PageQuery>
</TableData>
</TableDataMap>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<FormECParallelCalAttr useServerSetting="false" parallelCal="true"/>
<FormMobileAttr>
<FormMobileAttr refresh="false" isUseHTML="false" isMobileOnly="false" isAdaptivePropertyAutoMatch="false" appearRefresh="false" promptWhenLeaveWithoutSubmit="false" allowDoubleClickOrZoom="true"/>
</FormMobileAttr>
<Parameters>
<Parameter>
<Attributes name="name"/>
<O>
<![CDATA[广东]]></O>
</Parameter>
</Parameters>
<Layout class="com.fr.form.ui.container.WBorderLayout">
<WidgetName name="form"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<ShowBookmarks showBookmarks="false"/>
<Center class="com.fr.form.ui.container.WFitLayout">
<WidgetName name="body"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WAbsoluteBodyLayout">
<WidgetName name="body"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="Arial" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ColorBackground">
<color>
<FineColor color="-15985098" hor="-1" ver="-1"/>
</color>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WAbsoluteLayout">
<WidgetName name="absolute10_c"/>
<WidgetID widgetID="cf636775-5857-477c-92e2-48bd0b63e995"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="1.单个报表块推荐尺寸为110*77；
2.组件底层叠加了一个不透明背景，可删除使用。">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="b7e51af1-a2b7-4cfe-ba50-5c6db3a78baf"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report30_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report30_c_c"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
</FileAttrErrorMarker-Refresh>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1485900,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
<O t="DSColumn">
<Attributes dsName="年累计销售额" columnName="总金额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.SummaryGrouper">
<FN>
<![CDATA[com.fr.data.util.function.SumFunction]]></FN>
</RG>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[本年累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="120">
<foreground>
<FineColor color="-8595761" hor="4" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m9"X5PNS8:&J6JO1'KV0[Y&6r"_BQeell8iBGCXVOJmk4+@JI[#iW\'\59CE+c)4\"gh]AF&g
8Md;50-`2=)KCM?M!MKHu4ePG"KBSMP?4r%ZroF8.9Cq^'R:msFMOTDRDKq'#N`jf2%UN/W]A
H^]A3_k_a[+mmRBYm@4PFChh56^fk=pW@eos]AHUH-9(:#an&[BBeakn@fqgNVH%u9`e\jme_g
4WT*BWLs+?gmB0&@?dsj3a$_]A1u@5+'c@#fDSh/geHp<G5EU.RS#;diuY<!nJBu+%u]AgVF)t
\E-efu%]AlC$".^Fq2YL&0Kf]AGIZ>9TNn".,hKP]A\*Wb3X1>)pGF<p5OB*N;UfF:[G*mOdl!h
0Yc_)[Sd)'j5;8.?t/C>K/goQbc]ABgkN$f!)"m*]A,.E"d6@A,skVqDYG*CO"Qp^5&CO,e,D]A
dQ(&ZpZO;8cgpE&V2[9(OL`(YM%tU)T!tLB+BR#'ujm9'K^s("oAAEu@nB_"5[#b'll%Ktgb
;@27)^WR.b9L#b1B8Lbjo*1dt%Rs.?P7(*2+e#<_Pg(79"!+Mnc=9!53R'"+uN(TW30g2=V2
Kq4A87r1<-tD]A8^i'9sK7=(UU>FoKPV'*&%g%8%e\r1XM0*7lHpYLWd3U#`LI;s^`(HiP+%:
W/0rWh=4Z4ik(Kih]A^fNh"C5J$m73uRI(b8P_cC)!f*%nUe)GHf)H>>QcMn?P+Dp=`[_oQ\+
?<4fWnm/bt^Xr*;O4c8LbWk&Hb4\><m3jX(n]A'lZ6ued0rLWrFKRpj7+T`_;\S'lFWS8l3I6
&aeB:@X"cN#pa=46ED%`YJ8IM;00*@FMNJQcRJf"gl^['$\_UkN:>X!t=r;A9J^BT1s(Bt7\
)GP"RF\`2Tn0<8TA*!'5\/er5;Bq8*\DK*q;<Tn%uOY]AMWT<O.Z^q[??\_e)288]AI1KU$(C6
$`d/cr7=:S$TjiN41NjRnRY5@h[j]AIJtO/RGQgge9JYKXrPAUS^,K29e'uE%nP"&$^m%#jqp
-,&"D-e`Tj]A$'<"aQo;`NU1%iT<WT?!/3r39%Ro[KpN',gM;'`8\euE[*6lIPoB,k)._+Q-c
#KLbbA%ICdGcf6&<)UK<blEM,c3)'jE%JMn'g9P]A<O_US=*Q0IS9aP'1<uK?QdG3m/O-4Fi5
@9>^dof:dc"IRSOA2\g'"$UM!0jC*K*G76ud@LUl&Du^$kBt3)c7RI#N/K4[kQu-O89E<^hY
)8\=8aeKb9,cJ`()"l.57LsF/n$0E'Ylg8Jqk@j*sX6I'Ldn3P-kE\t;FE##"Q2!]A4C*A"H7
@S4R0<??K;UFsHK?cL]A^FQJhh'%TS$g.11T'8pZWFc!bb)C$KOqSYfRAa4f0%&)$S"30;e)3
!/`n/#`?9+G%WmAK4i3.oVF`1^BI9FRfc@.kF3Fj"'S\h4Z>/&_X_b04]Ad#MYV-?hr,,F?C6
!_TOPdSQIT]A@#70OJWb37ZE..)e7\#Lj]AniZA5(%V*pR:/jP`Fh="(LV#ImAIS*Rf2`q^;2K
srhB#=H3EK^,rMe,"3j9GuXZ<*f+[S?3^k8@n?9Hcro!,]AX.>g>W!ndqnB=;4+K%e'*ofl(1
Sq4eY1?Q*mnLJfBRV5X`X]AHf_pJIB`G$RKk<7AZ:&&&CeVlNKk+Sm0V/o2#8/NknGUnVYA2!
_r:J/!qeTB@L1ScYHLVqIJ?MEsE6*]AfALL)HuHEc`H5cDtn1kq\YCNANW&MqG$<eb?);:r[B
?^A\<;`p[#KEnWJfIZ5'b3=pN^<&GG6@)!O!FQe'>%%u&R*CPfYrY"LU$*nId2YkkM;L^C5q
3,&m9&.hEh0qnh@-6%i-?SCk0rl$W6-b?()]ABM0m-,hO8.7&;\!`0>g&PGO3UOd3e2_6Wfjp
#tT0$.`J9E&>@F^9l@+eAM[EYX>-^q+Pk08\La4@.dE**@u`(_*LsBV4#"X)DnTr,kqU>PQ4
mcd*s*d.P!Zh%?7(OfA03:k7BbQe4r7BX4:!F28mad'i#\m.oPd1:b<5df[,`g?WmfXKXh"R
B@X9*sn,&4\N.c))"8n9;`"571tMD-*5U4F=eIJ:e>d,fqL5[rD[AHf`?hOA.C'(?u1i5cY2
d+jFU;41s*#nIVBU6h_4A2PD\$Vg#CdVj(=3eWMEg?>5^2+2=`WW17:^=Bt;<C[l#91g-C_=
E>+M)C0@0!Q%Eh/Ch=o*J&hPk]A*7eY<DJ63.N4>nV)6%I;jbPQGD<jpSl?Z7($V"XbdoHc3L
FQQ3VeV$ArR!Yo,!tPn)bhMY10f%1!7n+C-&COG@\l)3<52CYDdoq;EcB)[,sP2'QbF-9X`V
k'-3K>nc_B:C6^)1%"R+VTculkrL6B"N1gh<GC%*DK4Wn[3t0rjZ$<^_FiC,7@KGN'?k;OcW
4ZQ@EH;\5:+>kCoDTAg7+^=)J)ILSL)_bXG;oR@=)nJD^P[%_[EJE,XpK7N#h.<;.=is;WFR
?tc'nj+RXCgJY`SBu#XtJP\q4Ng5cM]Am0#i3]AA,Ygq-R!(YLjY`gH/@qYSjJ01X_ff#AE4Tc
KKtj*TR$<*V8iC#3S3rB,!/G!\@1:-+V?sR[)]Ar[no-n`bYUuR3['Wa7^$eb'VHiHeJlPJ/"
W;W1X$Y_$9>pAU1=G$FnZjYP*c(Cr_0e1pur%hb\5/I5GcJ3l1:_nPEdQ;c"mkPR&M;7qNCR
HX:J:%aJaS\-r(m,S[:U2!^YrF?#C/Q5jTd/ik*Lj!3aRXbX?3p]A7Om/#Qr]AOWSL.X'NR9op
*63H^HtO[-p_G$P^[I^:1m's;$L<mPAgrobjKajK?]Adt1EQWLZkM#kgd]A'O2`W+:)b?Ne7We
CdpAK6aKX\L06/4qm8Tq-FI;E?2VDObfHKg+k0@J,iM;TUuE&0RnTBfr6gX3+VNXm[o(aV!s
J`\<oXF8dhLo=fHW#eU4r9;K&J8aBB6u8?s_fQ&GUCK5X*\0E=:shCR'd!V1(\dleEt-Eq1#
?fmJIFu8NihUI[A.*#C2=8I-%KDo'mqao$SIp^E^@&;rc2LOCq:?u1+KrWT*6mT`&QVD<H@R
hBb)Z95DXjK@Uj*Y50dO-$/#E'i[f&\b_2nF?9:EnHe+?m@Tbfk@@YJ@23,r3$p)sD]A;*<t;
cQ><?/3/#C\3_GMi8&FJV'%cE57&>/Z^-Z/s2O)\^$VP"$q"<ias6q[1TIL`F*9KVUWI[m7&
9f[K`4-K46E?]A-Q,pP"AU?8DhCb\^247l^g`i,6V&1s##5^;KE>3%u:$URoQK_Q01QWB!$Ec
i!YuF%tCKhcoLdE!Gm\W.KMtHQS5K._@2;$4;M"=1o%P")hquJiGN\FX[%7PpWrI:$N)B4aR
2g)r1/XFW:)TL.p,qj(cKbXdX2C0<83I"lcW!GeX@0tl&.+D(r9G:XX^kTpg^+H:eo=XO^Gk
5<b(N'Ebp^s[\)uk='LuEGQ2QQ*0X?#6+^9)g(=;'NOTN(q1(D\BG9Rk6,'hCDa@i^1aB<&e
j03p;t4(-K#+[GZ!/Pp)3jPQFadtjjBSRr'1KFHqC#;tmd./a8ZZpS@uaU(G+5e,@fil9C/1
b*pV$!Ukf6q0j*Eub14.LR@T3AA2tNtq]AMp.gpY?M^.XBO?),%8[_/&`9knSNgH"ijB!H/Jc
B-@`^E)%G&5Xkh9O"RcQK]A/u8kjnKZ?2pY2WKKkqGTV=C%@d+HN%6bhUHtc^ON1/[PY,lP+E
Tpsc4r_H@drK0a?!NHBu6XGXR]A-Vi0Wc2h%dea-FW]A*08:&!\eU.:W?`D'-n1;_Ul@.Hl6TH
4ai,JDCRo9]Aeui&_F<p8p7N"0[?!oBX$7me/;,q*U4_fhI`oK6@Q"_/[XlK&QiL,is[R40;O
-QD7S.9s.F(T$7'E,tKMo>9N_:Y:^RG8&uSt/l]A[3-t'(;+\1ghG.p442njbqB@FF1YZu\%Z
e<%MP&7$hY]AX0`<UJW@Tu,?5fDI,rucgX.7uU8$XMk<=Q=]Aha\I-La%>/EQ=[kS3\1M%4c[:
(730APbdeogjWZs3MbZ5gV:9dD!`PA$I<uGKN3]A@-`Z4DB;lU@Kp8aCisXj#dbO]AAloH^jn>
PAF8VnY+c&AP8V7^/sYYe*[MK:$#I4a<er>.kXH&$T=H9++M13IYKicS>q<Gta[*Pc%MK8&r
J8J;Iknk1\_.rL,j*E1]AZHTO=5m<t8Sp8N;8r1uXI_[@(BbX\8@;aKh$]A*Jt9k*hBBF_sP,p
tgS5S@5a*&m+'b#cqN1#Ui*(eMbagBeu^ZicdE,`AY":k2H2EHYi=2UTngsL!Ujm=rmG%7r%
H9j%je;%LCVHB`7G9fV<3RK3aD88>]APiD%2UH*iPT4j@bmD^-[X^m0Qg[).l%Um;cPNVp4ig
rS.h+%3!NW%$`9/ojm#kUuLcdc5-W.A(R)i^&Z68cl'0rL.Z%c3--ElXQY#leQ0R%(B#?BGS
PheboOpJ*ZcN'+>g+WUkMI,faThd=O33eJ:ep]A7')q`*,IIuWe!i5`,X4Z_0(c*)r..X71#_
T^[j%X]A.[$K%hGpY_:fEcMop7\!e,09r7]AdP;)(&7PMH@PcmQ=\'$1`oe=_(X#^'7Mi4R:gN
7LEh*Z_2W]A_.n]AfqN+79CS@4*>:$l@n^24S&L"j1!@e$Wm\ARjclcNQH;!jNU*uPLA&21Y]AC
5:X*gVE^NdV_j$@6U\NH.Q<6Q`X^l!EiYb!@ZUG3Pr>PcOUa0`KEWaKDB3!f0d1+FR'UQ-O<
Od[/gEls-]AJ]A/&RBK]Afo;\[R7>gR(DS_BKP.6!I+^RoD8Ke*ZD-Ub[e,DNacqQB73$Rr-WO]A
^.jG=@>R>^dOnTY=[uYP;)7(keu<2VRn/kb<EdZs[RUc2lACPk<#O?&!t-8^q\6bSI!Vp=`I
E)5\Fs3OD:)J<JnWn2)_&#tIpW"<fm.8!hIdjh"O^>d:2uPD"\DR%V-.,1hO-"j_[SD%5<GI
8q7Z7lB'YfLb&j)c5k!:C:!<+/YJF2EJHdgC=2@#NL_LmkMQHgpXdYfaoi]A:B*'j7V6iYS`l
-3HA="Q=!b$S6-1JEVrP8q)2COnf6R/p5G6XJ!qKGa1R@GM^u8)E(8\]ALG-/oEReF((K't!^
]AB4eK,:HhPJ!^a"Y2Ogm_6q--p[X7;5E\c=6H_GA$]Aa^&Aqm2ImXLsPlrH+)=6nCSONDZ?ZL
_[G4>SF`4>^qm>,A#HO^hmEP'BlJQ%.1\!3U,+aI7g"4qJY#p-\?n8sW8h'5m=+6\@<:O9[t
c.&,TSA*"*e=7r.nSP>7^%`DH`3AC'EJ$/OQNnB&7WDG)?Q;6+l=Ol`p#/HqjJ`^#AU8I[FX
*LA\KpcQ^>L`&X!8([Spf70SgpZZ,go0cpBPI)g;W7tjNXPrZIBIJ4OZ-!:#=04.1&*pHcD9
*\15^,r!4#6ieP8(Tkt1G3NQ,@9:&HL$k3)ee<bk5TaY"4^0q.f`Q<I2+Z"cVV@bEIS<E+o9
2Z<M_9"d>)\oZ#N'LR35A_1lbWD1[(G]A-u%Ob(I<LMUf9`l<Y>_XN-NF=4F5KG`3e3nED[p=
EDl6WmoI/=)GB'D(Zfr8RN@7_L]A)D=%1Ri_+31'\]AH#N-mX@=,5-M'lI6L#d!,5Tu;"LHX=_
L25AiX@V_0N!o2M'4.ONG09/L58E.Y7VWf]AN$X^E=)3q!LiU7bJKU[\5_[_>3+L,Z/1h/fMk
d36'-=K:]AO!Rhc(G2Qop-'EGf]A%pNM>i'co<+q.T_NO/%NtbHM8_@_C1a&a>e:4meS,j&aoN
O.%c<8ER60R'.rq4g-##OB7R!7p_X%J4g0uIeQ2^<El>jURU'_sHHH<k?YI^9E*oX3CDcGP(
-V-<^:mYPA+8(rH;$UVJ595]ASDD%do>W9:6$=(&\Xf4Bm$55dlY<JX5#Y&**9b-/[a."Ur=$
.r:?X7(>!YS#'fAc0bitN_b.^Pj\c]AjfS0\`@u#IM2]AM/ZPJCDd!nDt7.NJ^`-sTdL6J/lgY
="WQ5?f7iBp8&i'/^cQ.)cB.p4E8-psK#2M']Acro-pWjhq'o"ctL60HPV$$%1SJ-(uZMMm??
D/70hB6Vuq,P3EK+]AT[`,cT*o'g=r)8_@rY(lRlZdtS`E?jj34loSAYRoXNI%PfOq1?dUo#"
<s((8-:cq6,<"0iWSHERBq]ATna(n75RmWN[cW;N(Obd)+`!9_r"sDp)=%X:+?1U5\HtD^)kK
5Ud*"'&'Al;:f^$Mak:,W;mBO,O&SUSI=)1cR5V68u%lsY@`W><*>P:b?d7+lsDP@e$Hm"&\
W-UZQHneVq*u$pgo8kU)3:_U4]AgI41l<ipNGL<or2.,CheBNqU.cUrVF>J:jCJS*c$]A2nT_\
JE&Of1\m;Kr3[Pp]AqG;C372atC42O,6`f'aYr-5o%kudMmO7dCN3@+<t/GO1ijbL9Ur9*]APO
o,'ISln8H5tL07.K?=#r3%04_ojo%dS/)[1oqU=VLP3K\oR?EebB)0SGp-]A5/K&0Ij:_ED`a
:)5#6PCotPNRe9ONM*>TBg;<-ZcB(T6rU6[`aZ>Pd?F!DINS^EnA-1DOl$+pCI!\]A+k^e<T3
n.KsP]AEDOB07fJ*9AogeS?(ZcfWI$3<\ET*2m6?GB_]A=dn,jZ9Csgu+\jbYM`?4fj04.++3.
*FBEc09JUA<eL9@,!K&p+Gk"T9EmY*sSm@:T38^!EqZIXgiGF^N&3rsJ~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="299" y="7" width="114" height="72"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report30_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report30_c"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
</FileAttrErrorMarker-Refresh>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1485900,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
<O t="DSColumn">
<Attributes dsName="月维度总销售额" columnName="总金额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper"/>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[本月累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="120">
<foreground>
<FineColor color="-9302" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?i/uPLm7Y)-!Dh;7Tc8<7#qgYqd_"6jV2o3\dT^L^]A,:5\,ZZ@7Wq@6_uAu'd^ZrZ!*gE6Q
eW:K2kd"J-]AQj8PgOg8VE1QL.i+SHgc<2]AQO7!CV@46,6-_on&oXAIJ2?@T=sjf):oN+?[V[
'QBmiQWKZ51e'_E6Xehk@@J-XS-Z6CSX0f8-U/$,\oR)&31cM*l4Rb*j;WmHkj1>hagG]A!.E
V"+H0*SSpgMk`WlJR($N.8spF]ADEU&&Yc*0+U8#FO8FsDkTq@5MC'U#B]A2,ZX9gF4"uokBPk
YY6US=`CTgE.Ph4(EJo`XH0=W4[$;e318LarX]A%sCp$i!Gq-((:HhCZQ(BAm9_;o&k<B_BWn
2PN,L^GrGOB#_#$Uo"BE\M/[uXDgB&@\:KRd+Y;C#0s9[B8(%r-Uo?<G;j6]A[RaOp59FeA]AG
p`90o>d$1&1Y)JpSfjZe2f<6ndHInX@Vt]AURI80BC4bUGd^94DJsSr;r!cLha[Jm-]A[TeK>k
g/tns@d(rU+HPDqt1E4">G>L"Lnu;o&B9\k46V?e1'0I/'ZsfKDjdh%bK2jR9P,o/.o/MIeW
<78UM/&-__^_<).PX(tlV=t8Ju5M#?73jACs*:?cX0G#6a5NO]A.d5`#HZ7*09a_+?s8$7jTG
/g\_.$SEO/Y-[#3+m!hhROaJ.j,H?m`<Ld5;A_!Zb3:@+HRG=b)\"I'5N4;%0`k[B]AoaIe([
UkG^goGKp8LI'uSUgf^qX:\m$cg1/QCnW/FO;0IP0S=)2#hguD$NuB<i]AROmkY853fstYJl1
Up+X'i21dQ4Vok;5#7UQ=J6Ya)CmYlI!A*#.7'af?kJ$o]A2!IirG*L$k>(0]A]A-2Wc?m#(M_)
IoEc)P[hHd_m.u8e`k<%^+G+6D^D]A0GilPf"*irr3Vh]AjI&_4ER@U%j-%WIQBMA+2-dq"5ph
K@FLWH+Z33R=ZCO9_opc>BAipf<Nt+U.<0A2f'WOLaTsh\F)7Od4X`=Q,P[DJXl(,;rd8_$9
6B3bI*I-^+La_`$+:r01`)J(V%ZGG;KL'@e/cOrF=[UH!*9.BqOOLc4,QPVCT=;u8J359n8u
P$_Rq$2#Nq[0cUj16u!Xj@WjaCobX:E`)<[Ghe'DY-$djJ(9q#@E13!bX$@h"+IS3k1T@88\
XZ?3OL&W^2h;#W"dnQ*X*A>2csiKB\OMG6:Yu7\Ee+q-o3U+?=f0b-\V7"`>*f7/^a6uHKAf
8\+2h[fi,8>%!.cR_&Ns3>Yio_#W[\:>bJ#e'noLE-3KVqYucmZHPq3hJh4M\0OhbU'lq/O$
`uup=R\Em+:_I@&eBt[r90"cVPV9N,S$c$F1e^,Oiqg(&S>a@HZ0(djHI9LFc'DNArI7;VoD
]A6p"m<!1J_j6BDCgrDn1n$k>EGY_1QbP&kh`K3bVrY(@\C>qAE"ZbTBW4N&=B"a(FT(igK%Y
BW0n;7O50XU6>@dc&41e@'j^]A>ag_ap:=HGPWRT(pQ@/qcRIhf8:VFhPWc"@+s0ufo,M@-%p
F]A2!SLAkc`WRoL-*s(m0/2,p+grq7S/Ym\U;>5Y$"P(k!01n1R(Q@8L$8pqEY6(>rUD9FtD8
QT%14U".mpU&;(h5JL!nJ)?MTeB=p"s&/tI(]Alr`Z/\s:,6#Z[?G9=]A&je+'h4mf;=9HA\r#
9M9A+Pc%tJa"FRhZ2V$@;1Lh.s&[]A,+CBu)m&@u2_,j;Dl_YT9/T3F_jb]A5qG+1<\6[klNs1
g%q4g)mrl;Jo7SBH=.FCepOZ5"_Bcu+$J_oGgHJCW5k1!&,18di=k?d?1%9=,LAJBEi=VaT[
_OK.bGYrs-3;J1/lM)M-qRpPmhKRS!)LRuIXYh78mHoa-L]APNPWK'9"LR<9VY]Aq=_e.D42%q
\bU`$<"Q5QV>QfQ[Uc;=+XM^h':]AEhdd6QIp)gg7(2m]AO2IlWcW0ifi-h[rc6_'rL=<K8cH?
GhHSs*<uJpJBg<`='9s?I6GPNL2bHg=,ODcHQ]AgP!<G_bMm>3n/=h/OF2PN^]A?C(cNp57P9&
feb$m[+M#[V(=?>;`4QM6GY[qN+.=JKJ6VhFu]A8+ZA+JHsVC;f0..2WJGbb:0)9i,:3dk'49
D\JBLV,]A6PMS(nlt*TK#FHN=X7tNmTVFoU""u0jOfm@8S`R@Vht>9>pXl+312G]APW>)q$gbh
i<klPMSccX(+0rn6b_NPO!A?3Xp+VOg+n;_]A(0GK6R:LN>Im&Z>kt'ieRf#Y3?=IbTj=;+Ji
NK_f4q5jXXi,nPCjc$^a.jEUTHBrLj;1f3L4XW;0s5X:5>i;EBt,Mo242`ip?_e)YOPnP<1]A
a%1@bW.Pk8npi52dq(LiIAn%,6c%iiRFG<KtMW`mJNj^B<5-*G[$*ba"g4+_$+iY5V<^i_(+
*6%lOqQJ<JBZS+8I\N3X9e6S!eDffWZSQ]AU`28[_O,!<50)RrVXek\J,_j(<b/hmM"2&)q3A
g;^MhZ/]AG`p8;j^i91[^\BK!rjs9'L[`%bEamL9!!#HND?pNdFLCl,t[BSK+iQ(e.+P_^6=l
)=(pK5dWQ,X4LsnPJNoorIQa"7kHDZ3S)Wcg<L&nV^SPF$8a@7;uk3[)G6\L`?b-f*_Va6+C
,8s+/i-:M9KZGX5Ct4.GK\V#9q+R*Hct!6SnGAFH_$V6JK[(ihapob5ml]ALT2lplc-Mi!q1L
\O7@=ek;U\(?[&>VG:l/D-]A7@#US`,9JYYCScNajVAg,2nSN9$h9)="%X3doMA6@ZuCC1F@7
lX.`JdejV(-o(nJiA/,m3HbW0("%"eQ&k?(+]A[>-CADT(E6qBo\ZseIKAo*ZJ'2B%Ff!IWV.
BKWjjFf4"f/6WiPBi_u`IY0Qp7W[[lAo%[CBhW#9kfnpdK)cC(i-Rsq3p$XFI--_[,^V+[XD
d8BQj-[2UK$$rP^4AD4/c9Y/X*%hU<a>qf:8s)6?;lH=jN;R)(aVZ6AZ#QpI_YbkV@$2>p2,
V%[Oq.:-5:bI_QVpQa7iB;^N8=!s=gul-X+i8j]AHf9VJA!X9Uj8Z8!.:?m(oI)WYe5S(TMR9
aa!Z"J;<.$t><Z/rJm:0^FYqcpgGmUcCL`ZufSuh/o4D]AB$lI9pT'"D`-(?CVo@;2n&99<X9
VdM0mtK5W%hAXB4ERY@F1NA%\b9o6[#UfeJ0G`@nVs2?S2HeCa[!TM7iWLUU[k2]AWqT3gV`n
\'mFm_.pWfh#7nm?;X*;'H*fqt02OfM+n]Ap?QfXem+`7JtK7s42oK`Z-TlG]APsSc=F;$%i)P
GYSnn"SFTrMo?TAPn0Tr0KZF=mWVFN"fWTD<T::%gKcta%,4@sBMb0[GV((GM4Lm+!?2n3ck
Xc3["FUb909e#8fZIP#mVKp/#j8>n!iIaj@29s@9(0p@bSl$iH:*"H$j+(Zq%>'U7U\&=h(P
oi0C)H9EAW.K7*u&hSbOk_`sPQbCBR"\_27"$U'Xk(u`XiNJX/?"KJ%_\;Dhf(?A/fW]AuVSq
qh-EchgW<2pe!1r(idA'CUZC4fteV4aH"7NbsB*dmd]A-]AE`7rF0<Rko6l^P&b=j[Aph0Ype]A
U;?>)(Ifhp`gATFTi!e%6O&DX&oAU?j#,!eh1=_8m`YAC[G7Lo65=\<Ga+6q_)R\60uLG5L,
C-&4GklF'c4$FB2qm@_5MZmS?VDLq:@2i3&.OFad[LosR]Ak&jZOo_$Y98AB,5\\lG^@t4tOR
F.]ADm?b+O2fYgf18KH[/`?[]A)K/E1]AoLFIjjMpeH,YPF+sd)+(i%oOYp]Aq&2u:PTC[8BnU>S
InE0ChcJV!*1?Ju?aDVV5<>[.7S*Np7Q(:iC1hL]A.l3UadqIO]A8MX%>*!(Uo%CeK2.bEXO?b
^?6mlW/A%Uk<QqIeJLr1F'=m+jWd;:E#oPo:VK_O]AR0I<<S#mOrZ^0'(;RQGCY/pBcKta"Y)
"fq'._`a$?qZ/e2[bR8`tcGb$82>bW"r!t[p1:baqYC+))8A<O!.I2#AdhOjDJ*YXb4Ug"V8
2B.d7Y:#-5!W>4Jk\g?61'BK#.k]ABV9M0nLZE/H!:i3G.@qu@.D8>YT&JKc>58'UFOLp3hHl
H)g.^fH9^#?E6^Z2Bm/]A+R(F:VNS]AKBVjJScF4a8%LtPdQ"[WcR(;YI^$qCkqIDS0"si8t&n
$]Ak-MZgK!J(Hot))m"mWQZnjcgSTU8/2=E&2`*!B5hDai@:mcBUqJkhLdK^;J4E&Z.fVdT8c
m@K9Tk'IUiLj8?eE$4Tpe[ng3\Mr1k-MCooh:_%GYHtjf;9HGd^Pr2KobbpGkAG@M0$uW1X2
VALk!MTLZ/g?Q1#c2d-Y7h.b=D-NT>Gm^EeZrlM>F2/8_&d5>sLS\2*?OIP3l)-cql[FODKC
V>`jC<=tB9KsjApEV6/OH*Rha\n(6k<QX"Ro_d7<NZdudK&L5?Je#03"%Tcp;G2'$-afsuX_
LdjNbhJgE'q^I7s.O,pYpe;<Jkh*'g@N<M;lH$e,lVt`[#i3Hau/d;/mCdWHfT;Lp["`,_o%
0BbP2o:QUo/&N=YEr5An<gs;)V+3eJm*Bgj*9l[pO-jab``Q"ptf$WQ$(8Ji,BMJU=3Rho85
0bACY]A1?H%I-o!N<5aQole6O'8UK(RXZ&O#-n2p&s]Am7Y!.V'O4KpFfT/+p)GC=EFXZLMf<=
t^fF'1JF*<>."csA2em_UI.BMI:a/NXV5Q4i%G;D9bXscr4C5)$uG::5KrMOamKj$:uU:P.a
]A:,%_r4LZU&J(4!W^4eMLae'7-)(!:\bs>SRj4RZ2d;V">Y0)'A%HcAnXrJO7kaBd[_<^s$f
L_2RPd!o[P>Sb*MMr+_AqgHpgibEpjT7.hI4UHa_aE2/R7Z,X[\54VeHq9Ak\M]A)M-,bqI)%
8.d$'gTC40_7,\tnlBl.T)u,K^aMeP9H8*[`)NS<P"5YqQ%if:tGRm\D7.mU@ft3GcBH3f60
U9f*OV6!]Adu2).@E8`=&?c:=d=+riE,pcJqdSZ]Ak?mi;#8b&^m@gU3'@ek-Wn(cD6Gc<X44p
cnpNC$tKqbLJ=YbhE8)!Un^-d?&m4/N^Whp!VhB+k0Y\X$pJ!.^eUt[j0o0YG<$gQA=lh]ANL
P3+\tmA.ogF'bA_GA3@9PPAa0B!D]AVWJp;P8PLU*@(?)#hd_g<L#'XmM_8l:_`+XM]AKATWI8
-m,h#,d+V7fU.s+">-@r1or9h<lV'?=L+RNF&;[A=E>QD7f)+kR#bo1bm9VRuN_0kQe!Bu(P
09_\W7NgGF+B@KtnTT$eP(e&%knBFlIC=uG/0gAnXgpknt$i]A'&M2?Sp"18[7)>5li]A-q3tm
Hp]AuT<D8mSW&HS?AEDa#6&(;!p!e69QXTEEtj)og#QC\Cs[u,0si,f]A1R>h'%gHaDY!':NWQ
"71$i+jkFoaIYZ:2@'sKm77'CIo6LY0J"!t)'cVS@Z,\"R"`\(C&p+#Sr`*O45J"DOXE,7dF
PaW@,GoCt"\,bZM:r!UWU$DRkJJ:SO+sQ6S*HG>j-)]ADR@b?@W<(3tm;Scd_"f8_n=0md?pP
tF!fpOeV^Thh!iaBh=C%gVL)0G.@LE1tJg=nB\CII+V8KIjhO`&niNP4^T%g,-f"nj,DqD8O
J_gB0k7#(l'j*%me2PoLooEsI;UORSAp/K6B[_a.gT28H7&-T0_E&`?YcYTE)s0GU3)]A$`UO
\@?u(N,?LoS1),V^\@X.(H386YOM!.:QQ"\-W0ik@/6hb'6+3/,K\]A03FL8>B%&6?tH6,^(r
irB^!BHk:t[Wa(H\]A^45N.D#8flgS7VXX">W!^CHEcLcjM1a1U%YX*o7"!V.<Znf2la8>V!1
>Wf[*'ms.^`""bDA./'``'9rGG&t9ei"Pl!ElMmKK"81[Y-(\-p9C1Q4([t;d))D&ouD'r(Q
L.WaqcC"S6s7oUT7N(&u*VOi^6Z^iY###o/-E,__kl":7`e>cS`!o6#HO>q^[,sV`-3:<\!P
D&bTT$W\PSYL,!==4*mQGMH`Mt6tNK8L"&p4S*-@Y]A:Y*f,m[p8#gTrDdU?IH99'*!#%WZ*F
PEfu5;]AX0a1sK;jV?Eh<2Uc^$O6*QO(UtTqG(u+TNfeOd%]AUEc'tg)8:P1)%64f*j6;??fr+
@OGHrC(E3LC%orXrRU5ajRTO5BP7Zc?hGoiJgF$#A11PgCpntMQiW1'a$cJ`-rIho7=iFDTG
?0/_eaAnY2=cBoHJ;RufR>5r`gAf;]AqLm?(BR]Ag+laI6<@NF^gV_DJf&ijhu_i)5<5I>AY$4
B'EUR\,]Aj"gANqF,k>/+\O`Ij<MBD_*]A+U`Vj>e-%<pX,NXa^DX`T`Nu08rs+J\T/n?ls)S.
Y!a85=_8f#%l/GTfY-m,#WB&Asf3bQJNpL&OfX-)_>KWO@<@aRU^U@]A*rI:L5Cu[:`$noNAn
1qWb0>l!&1;"#K_oqO)]AF6I2bOGNGgnR0J=LZ5P:uR'3]A%7Bm0>2ltIJfYFc4\^;ECgKnl_@
;!MPW0[bs!aoEICDFR/SkPN%UmKkVE#'TH4l")d&53h<;i2WUF--/,pB6j$*M~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="161" y="7" width="114" height="72"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report20_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report20_c"/>
<WidgetID widgetID="06bae1b9-86d5-43d0-8389-21d71a3ea643"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-16636871" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__81564603BBD4F6BE6C196F5CB7615F86">
<IM>
<![CDATA[Uq9QEAPq%_)V_]A;-R\33Fum'S@N-?B7`SQ%=<5"`VdnJmrVa;\p[)!u<inN#bu%u13Td?q5?
*lCOV%j1^qdaIAS!.:rnU*ES\O)jr`t$MPSet&GsoeILh_1rT)6Fj?nFT+1(ckW>MpiO@#=m
&p`0n4>Q2!`NJ<H'N@c;fhq4M\KP/:>TjrC$'rl"\^b:1+2T9,fG4d/'QcId<a@N#5P\`O)f
/5@p\X<VIb'i"5S^%m^L*FZPN07^,7?>h6UA4ce3%lW]A,76/9iUT=8ql(c_b=Z>-P_(Wd#Mu
/0ZZddoI84_HLIGN0*^c#_$E%M$a5OJn;1,`3P3DT7qsTHL68@GkWMWX0d_e!]A)qEFeY>V0I
B-MZtl_iVF$/.L3an)!]AUpjfAn&:@FU-ng,j2LKR(5Dp$j`9;DFg3L-Yf]AmC1&(Y]Al9.HT@;
q8q-/b-pld1<na.R.jW6:,i@o:WTCFV)-h:TpaY87X;AXefW!U,,Zjk-N++Z'grk=]Afn\ST;
W+KUc!6[l_\N2MEA%6B5K.qfUuZP1X+OR0kS_,-$>A]AN>NNGV0%:=dg%l["mEj,r=B;f+E.a
FJ`+r>UQ.a=Y`CGo)*06)9BaB?desWhp`)J@L96<]AT-DQ]A+bRO*s8o+OS4HN`gcJ,+]A2_&9"
?0A"rO*a@N:^9;=(u2E'"`Cp5#`FkUjK-`>s%f1..J#JqX1Puf6c.WNhaSedG"9@.<b@.*Cs
d3b6-N*,)]A7KJtgs+G)R"InSreU3u5EGqDD+h&X/<CI@dc/Ucr9JZTijJS-WjRP'nmOJ\PHP
5kbQAgQ(:k??a*eP!<RhU!)m1T(2Db1+MPF:q`Kdi$KboenFP";mrQBf["=`l7WjgeOK!FA,
e"*oD(\W*:Bb`[?)U@tK5HtBN'ps9&AqGJ?Q@Y\eXl4-qt>8IK5bp6R/Yp=S'Jss:Wkh$`(;
J)Dn$$UnM@0,CNAqK[<#-:d5h&6@"KSJF#kb7jBABaDr'EV=cb;r9W124mU`P//Qr.SbqP+3
8_>IH#($S+kDMnPR\XlkN!Nj7C%5sjPBGF5g@82I9c5mP%,7N!"g#Y-Tj.8^=.>DV%,&gTIg
2KWJ=9YhY3(.Kp'+&"Kobp(]AV0,U;]AFO;o'8imd,e!M)<U:6eLe#KpDJj1Xt#V(<b$h?^(\C
ea1O;B*aQR\^dE3WV@Sg+Dg:_$!M$h'8u[%cHm.]A<F,P4#Zn[3>Ck2f%tA_WFIa%I!Lp@A]Af
".e]AAn<FHC(cBaZ&9`9(':M$Hheme'a1enmH_C#%3?Rn?a2T:h61<&'gq/V?"`#g_<h/6dEL
e2EML*K'6aDD]AK$$Z?q<1P8+M&]ACHBJ[c9KS.9-0F:oU4$FffntQQbU^9d36J6iQPKig#QH$
<)-V7h0p<W+bK:ZtFaCSpuR,T83graB[Paa/n8I$YbM2NE:ea'0n>30;E_`Y/?-rt:C,h87F
.$6T-8WaoQ-?(mF[W^+4GEUAJUfC_@_9CDLq%k$]AdoI5En:!m,.mAP`5OQCFlJni&-f;83_c
ep?N8[+ZN2="/C)%LSe1PUJ6.=$fiaF3W'F2_]ACuDl>^9J%jobmTC[)V?.O.EUj4%$\4Zs9F
GL\K4oCNbA[\sH%^^6Rj0c'Cldhq+%)`K9uTAYa]AqfFp<t>i%g'k\_!c.m#O;GS8#AC.fV0q
,bagoX#O;YY1Ws_DQMhiZ^6Qm#i*"c6pZMU%iOEfNXDCI7Sr[\PFZEN<YkAiC'?]AUsuLU@:;
9)!r#9+%H4"NLcg'q=]Ag9o-.A&c+P^-Z3j[0"e0InK<CS0^D-Sos$JB6/^?m%WGlkpO*PS<]A
A3'&c_)'!aYq&3V)C3.!bXqOgJ.6`;;U@<0(7c?m24)pV`*khI=5Pj**P]Aq[:!ui"[rU"r>!
OO]A'r/f)aI;Mdqt)XI3:j)8fZnD7j@5M%"#TX'%<W&]Aa:&tqh=;f]A%`H[Q[NJomLp$:^9>fC
_4!D]A!KGiK*K5rJeNTlBXnVVrfKu8!@>%#rc3tjU#$5Q!/%C#blOb?f&20Xkafckml'l$BPM
cXkQW.Ud(F`p.8Tc@,g?dkCLH[ui;PomG;LJ^pT0:amY"1ZJhW\-Zh,m3uoU%Y5&0m83_=k8
L0(X>l[<s7&keCF69`ATAaMF[dh7'4JV3jWJ\$!oFHB#?Wnj9`2W8rUGSTT=oGhu3[s-X-7U
oI]A72I5A?G'g$o_Jpf*YPTR>o65b?Xk*8<HM05qC`h'@Qm,T&_TpQ?&!sCBbGZJ\nrb'c6ht
:>_pR`C5)T'BBN?QnM06T\WfgY*KY:=%edF4-2GHshdRXA1)\Yqj/-BZ[["[.prCg=pP2:/K
"L+OB$3*Ta).qQ?QqF?UlYu/GJQK6Ci7_11gr/tcq(;th-S4LE:[jEg#EA)73FD/Vs.^,/XF
.I)6,2hf5bm)OTdr=b_pFI6OpkZ;O%36jnh'i)4?Nd-^>$\A\m8:#%A<2g%3%pT^dT<S\)qY
*=:F;MffKj+Pq&V]A^Ni/G\f3&iUqf9gZMt[(ZWB@SDb/!1JVhH%5!>3L5<_!>Z!BZ60OK"Lu
8VWC(\)lRVV^<=3;>'/dh*1?Gq7\f/I`I<5a"=L^M`N9<e4qBFDKZM.B<<?]A)`9q*8uS:Kfi
do8OSn9LDQf]A8fWHimN-#P:OkGuIGApRK'iCc#$m7gpr\Wr9qH?=&NqKsJa)=D*fO0raS$$$
1Hrh55U3+7!D?$GV]A3_0Y3EG^id)C?H.2q`'8o-"V:D.'tLj]AsJ1(]A(c*#Yu,-N8Z)ZubK-_
b^'p\c[g<f5_^Oh;c6KmPT^09!\c7T?-TjgOEc.pL@1\Zru]AAQ62o5L*aHflnGnon)^p%E)O
VQD32;S(u(9.cUZ4?>+`o+oHNBsWkZ?Mdb"jf0;A=4(;hDH;Jr)A1Bd1;q1937VO-S(J-_BB
IJ7`e@JCTtAJ+\[cf4es%&sq*3I9J*'X+!%%g>DboZh-ahh!#TN6GN7]AHb$@.tc.GHW<Q7!j
;317Zo;%H_QC'4A4UF+muNJ[6/,8FO=rdQ.3$UP#n'&DXNPkgY6Y3hJY>L?[h)Kk+3>:7(=9
*:PM_*r]Ak,B/'(Bl6"bS+Fpa:aMr[^)5\tj8he"XEj0F%1Ag=4%!hu:1os6GJO9/S.?Q-5:T
3&o-f5'2*!7=7!1TpVQHi9CrhaWdP%F[A0p>Y18JZ1(X##"q^2G?80F/&VEj.ZFWr.lY;V2e
ok9hq9GSdSJ`Tgd=M\8-ZD+K+J;/9,feN7\V_+Bk"bkC%,`/pOqU!T(F)H"?Zs&Q+tUp&U`E
L9fLjBDRC]AM7UL2J)O^Dr-A#qFa"J]A6`oV5Dm$k[k$tib[K&FS*bEcLXCaKYc<e#<Snd?aOT
+r18,]AV2gt=#-l<:+nNVh&6M/]AYa$Nta#m0E.`214pNY.YlHI1L5>*,uAUI7o0`I]Aj(Y?m;K
Z.PCK>_VW^r,EtmH)#aI%/UEKmXbAbDnsJ]A":9?Xe\NuJPi>O6KKMC't@D2,hA>[rldDO4oh
3+[170#5n("$86."0*jOGm]A5[3k.]ACaRKa\((G6pWdh.`DZ_9^[0\&/"Btpnp*^s]A@BudTl0
D,K1B$^*CY3l09+"JZ*j8^(gt8#^J@$<3f]A2#N9OtP[uSe7VPab`\!Eb#rdM\2$eIs&?+=KC
X)5kg:L*ZG:-RP\c:gk>Kb802$1e':=7Z6_\:43?1Qgkrg`_/_RFY%!m-uDnj@e'KrLl`[T@
!%ga(]A$5KI]AOM\$)egUqFpD\mn'Xf".,J,7n'(-O3&XbVTEBj<f.]AN@1f=\9W!WpASlj-c=!
G(5&9V9A0Y!^b9qCUSXVGZQZXPf6=a.)idiFGKrP[<o<M(%E^t,/:aYLp.((cAfY7.9-?%+M
><6j?K`)QN(B-r$mi<jJfHIh.O0tHr3EJi._WY"`.-57>ZK=GpWi`1op2pW64sic#^]A2BWZA
'GbpmLYZ9CC:hjD&Z"tIT9Bc\q+qX7kg>FdRQHqF(faXr11N+SBBg00&MpF]Aa$T.b$#F/_*Z
5$0p#(tRTR4M?'9emf4%:l^MO20m<j]Ap2s5(hY]ASW9i;<TfGP_s2"/2IqccB>SAL`Y+9UB']A
NXqUlHXC!la:r#[\c#c!GI^[/+Uj't77OC4RbP=ofCYfkB[)B"EQ"V&/6ta,(j>O4DE)mCi9
#Z+)1nSQY?:h7RjTA5^1=3Nf``3W?_&)G(+/,%tRtYn3n$?IPRT"=q9d(o+QEa*TOIX=S5e%
XYDHd')SS6J?-1eL3GAShs0]A5rCEl1Vki\2`En0K6Z&#Hn##7l70b#YOr7k[ESI41AjW`qDg
?q]AIYsmo!=[gpBmbNnmD)_X.,3(&\f*Im;^bEBA0DSi,AE))UYVc@Y,dj`9nk;,i(0$`;kpE
i.s-G+:mipV8)g/*tLh-*,@--=XT!tKWbk=O,H:6DdU0.Dk:<2A;+A`+(*2dGO9rW0=PTJ1c
^WQa5&XCTl[F:a:X(g[VS"<mD7&>eOQfUO$(J@DT`jS4.l>Y6/&MT:H_A*%8T_LT;6pChjuK
*4oXTm9SFA.E+*ts=k9dVf!j=mpb/MH1SjHHA(1I$Qo]A:nhl"E:G,IbY4!<T\D6GWtE4>^0%
1ode+3G\0\/Qm14o,L2,uq>eE=/#TRZ%B2?DL"BVI]A/gaeB5.UTpK?qcF2Sg-/!9i2Uj;/RM
0s`p':]AcbQuPVBo:BZ<,'qL*\.CB4Tjo/KneGc0Vn3:"(#jj<m#i%n1q'I,);_q!rEN5AZm;
X\[_KG$D\^>?4qTXTdBMQb?F*:fk3/8#MgG*\jsJ,qio%FgiS9WIM[f0Uu9S%VKJ)PKS'q@p
IB$m$rph<eXiQ0C?"biJce40W_3[I0o03)0'MA^-F:H>T@\3S+*Oa;$/oN$M6:=0lL>Q3bs=
-`cI4$-\_!(>qrZU*kR@Dg8=aN::Y-JlX3^[)F#BTX!@<\bq28BQ(d@mn4N9T?I*J0qCp#X5
n<Y/NG@Gt(dC71R]AT3D"#g]A=Q>GA$$rDkR*;Aim:U09pm-6MO<6QECh^6hE``';DFMXoq"1D
QiWI9NfpZ\*TF_3WU-e+YZ)%O]A&h'^\&o7I7XG-n1gm?m^>6%>XESQ_`+X*EE$&1[#^!2h(P
6#CjS0+q=Kd1,QWh5R+e+fL%5'oViKf0ZCrPsR6FP`E82REnohgj@l*Ik5Pnb9e@U_oVK!'9
jhD$8Ic6\FuoTcb)[f0sofl#i`^WQ!9S.*Db-&mauq(gB\QrVCY+R"N.?KgEGKG'D0/bC3ts
B=o,3^rU0KBiHY&bfB%C7*BWO@h@:[WIPE>lpQFU'M7K]AWM!;dAXj(d.N`Z!NHu#n:h3cKUe
]Agr!/>l)&JML5_JLsm.@f$<MECJ?@!J]A'PB;Hk0h,X?5clEHDd;E+6N*@55n7ggiWn$13\jd
D;SX%UY[V'2l@2C`2N9q#4+>KA9%Z$H,1f%0"RU)g-S[GJW_^E'u]A8oL5+U\C_]A]A3*P'8TBb
,(/+kaAGu3/)ba:SRc1YNLj]AcV=k_W:!pa`mR:NB<a$'q52?*8H9c_EFX[/)IQJ4$/$7Rqc`
br@Qqkfe[``Br'S7CS+BL7rc,i)>)r"f\W7F0KLTH'>"6ij.9_u=89iOR7fUXDZN$plR(5*)
^:bT:LeXQ[PTM\G>g:95MDpV]A'B>p=?;o^AWbN<=_(:Z^:j37A2%)(5\aG!5;VAAq-9DN^gg
(*\!pV*QL1"H&2!k*R[0BDXL-uMY41m60Zi!8YGNK^.Ui[Q@eV)IOn!%/):]Aj+a7Y#*R6_3o
0ocn6tl8_)?0))_Di(ndMYf`g\PGaMUo"&/V&43;G5$E2\m`H]A\1e.8_2/kGDp_)H?FB'[mV
/8$!?H0U7hBF0#Fp6be'QmS!f8G1nel_,(`=e_;4i!o8W]AR$T/-WQ`np*f"4!Bshb-KlV^X_
(Q,^R]A9Z$]A"$VcuHFiT?jJ\.Fg$cUuo7E#6%ahiODPL!FMDB4=?O[ULuG@f]AE;hqM.#2Lh1k
XAMNrY:s)$tR)"U3#iR",[-%a."&%2A3o!13aRKHYp?<JO&p=NnNonZ9D\qH+9L[O_!`MuaW
<bl[&>9D7C.rd@@M!$l;*NfK['>La^>iC80&m%=7J3>\6rIIb,>:eXYJ19fE[]AA_741p(!6O
E:fu,]Aa7'D'F"aW,!GEl_oD^1E,]A0r1(+6Wdp["C?+As-$ao'*oOJsi]A26gLeZfLt4Sj^CR!
P"53ebSAWg(8!c;S^E=e34e#N8Q-fqQ>ioW*,SMbm1;QBR4sYjkV4*bZcS790O^HXZ-k;^rp
?l%C+AbZD9(^f`+T;g2E[CDPkf?[jS'oSON,.b:M%B0i9HSVNijQ\R:+Y`.gB11;"VSBM+&i
b%5=nd%R+G]A(!-[qZ6`!aR'>TQ9dYHm-LM@_L2eQ9LXO1EU[+*W@d>mo\mC$.(:$G`MD=\dR
<7%2)Vd5\8ES2++/01Yg;PCGQ_R(uSoo@p)fDftlsDhEU>rs1G<B$5dqbL@p@=htZCdhf+&k
pE+`[Z"Z1hZ;DUB>3%Oh>5(82#b.!r*o@UcGTG8<ZYAbAW,29\>RX7/dW[k4j,)t7(,.s!\N
-CKdZUW696Ed[:URK[j]A7J#/+UrRsRoQ!-"-VMO7%.$XEm#FOrYNG-##bD#l!=tS/PteEk7u
WW<Q)U^nh]AZC);W4B]A,\?DbpNkL8'<*X(qbn[I'o,ACR%GBPs)RYKLG4iOV1rU[S@Bf9M"Hm
NK8ES1!/oLIJThtLA#q^D7`'ao,Z-4>aiicOkUm1o35\'K1U[Ou6X(G,HE-I,lMn)kJVp@$7
b%B3L>0[YjPd%7GMZ=c"9QPe_s%N31%/Bg8KJ9?D@aZX&9i2Fci2$'BH9=Q*S)3oY,Tj,dPi
Rmi7fgr>?IZV$(CDK_oXJh,T0Ete%n[EfKWp&)\WleZR9%CWk,F&pG;"^;FWq,m0q=0s4h#a
7gJF3$/3T]An+[N8;[J>^;frOi(fQEjga:CI)"k,fc)7tZ>'DS^9&p-/Y'lO"/cUg4JqEEAgg
b?\N$&-I;A,_'Z64=#iA$.li?H)a%b.64c122c-;kmA#JhJNp>YcLU@X@Q+AI9V<Jr!Y6J+B
INuEr`<_3CV:Y6\DAUOBaHjj_/M:@q"M:B@g@7Tt?i5c5P/6(XE^qeY+@Y")I4$45Mpn-b'%
G1ab&GS`U?1f/??@bPJ]ALGYrncfZ88)frJ:`qLj0P:hnB&(DT@))YVl!*d!pI%*&EDnn"%*4
UTA0br%rl)plh_n4WePj9G3nH-:S:14"0IqFPYYr#=Oel<8P['(Wp*Kh7VH]AJCIm1^h?=lCd
qj$DY98j+aE28G9#o(!LD_m-;O<lVPqG/dtn'n!KlVb-53`;75PfJ1S=NL-SI7:p.H!UZb)4
M</a`Y+UOcaY)o@#RRpc*"f:3QSBSF9O%kNGuq.LX5;J6\*%8&$jr)AaDcGr,d6)\$r2Dt2?
ABi3F^[g0Z8/F+'=1sr)0JA+K]A:4Irf$;^,+$epP0Q1G1:![.fm4GD;Qpjr+M=.D_;bWUKmS
K<Hqmk6?3St^m,n6h;QlDZLG&u`^kHGjY/UcgR%2D0"a9oKl`]AbHWi;BD.5(A\u'>lHIG89)
r&,MOM9Kj<dR6&7&0HCQ):ReSe5&f:MgF/Al/+4jKf:VO,YjGYF^U"GBUBp&5Ilk]AKkJLmUg
LR'b*q?+ru&_\uPWE.:id.N5&o^t9R3+4BM&)IHPOG=TlDrF3\c^G9p%ECUM`Y.'8#h\a@Li
T?kLI[FR5^KX'IIQ!smL[>'?$q(3$UB,>a@MYs9gU"Xbu:=)n9F1E,e3'SPVZb`>"#B^nNdX
i74JkZU)9H("^A(^CeN,I"BrQ#(WJ/*6eL%rZ=RPKUE^h]Al<iEtip'aqG+a/$O33iYhcZX]AH
hgaGEi4k#X^D'**gVX+$">0jpg0&i>;FRijBjJ,(.J2K-89,nEl"$5J(bIpn3(.E;u6[#C%-
,VKTNp:<Sf[1[@siL&b46l=gg?$^:>o.*/E\cNYM,/(1'_!W_qkEW_r#qF&M6ihGS21Kt'm8
n!1;s-\.-jJrVbE<b@M51UY>"nC;2IYeNO5f`Cldfd/@b]AY3M"?13AFTUFaUTWhCd;&ReF&=
K1Od_WuI$pGM$ofj;XIm%S!?UD?VJNp)=\rm7.$E)]A(H,Do##*Jg]A*OcBkN,-3<aq3gY:^bp
XLC,g7E7[JS7!;'EOj=CE'Gfae*(6k9?QQL/,Mmr1/(K-QIW;P4n1i1glnB[>J<[7qJR=UY9
loBDk93QQ4^pspcSD61DJ6i,rCN)TL/_dcjo[32p8Ur<*s6*ts!s?)(K=$L2jsLBGD!s:24N
"/i\sC5/+6b2\jKAaK6ee.=oFhtq821`K%lc:["V4cmcr'8?k;/Ta<Z(dPMM8taSrXEPH=uT
:O0[@UYqAb=h]Au^TOo(gPbLC>W/]AN4lV/#aJY2;6.^dWsQ<XZ:RLBH/7gAI+,bgf!Hbk>mV?
+-ORd,IJPjAEH#EoKQ?CD*Z?:NETSf;4AZie;Lmd<1drX/qT`=S2.,ULuu0)6ZMCI$gLH3_"
mIMOPbR;NQ8I<QK3_#SJJ>0>tWO_1F;nM.O@,d/lR:t>LcaY=Zhl<&:W8am.T>>DK$U"DC,T
0%Xs$bOE#6DQqfZD5]AeEi`#YEi_cTE3';q3u5E@0C.'l[u[LWK8la#IF;GXP`(Y3cVM4/LU=
k16EN4$a/V-R`d4<QC_`IlAKsWjW8'9,OdurUOG2ks2am\oOfltfpUBPc-jar@e"&ZeP/mA(
m,5`)VN.B#;gc1)-4"u]A1m.r:$HGErahi;hTq??pO\%&mbG7/6b%*NJ99dD&!&R6j;cee"dh
bW8c`nCJpX<l<Dp^%q:Nq]A?:KOU@DjBXip")j<D7(mqD3^$=DmcX*:ET8*L)SU>WqTAr]At-6
l;;n0&m:1q!e<cU@X[1+"#e-iE6gg&kdqh:cq-hj*a3D3dL0tM\>Yio(\UqWOR(`4MZpo9J[
#YMGK>j.I8dn^YC'6F>d+iZLB6uD`*+u,7X'PVHAnCR+>=\U&#nuB1$"ndoK_9((5>#^nfM@
XbBb,@u4-8]Ain)7AHmL<.Zi;r.iEqs/"Sj1-`PWQanPmLKidnkD^r7%qn.@Wia?`e8M!nR/q
K_+fE_K48NP8BO^m,g$)Gu'#1qTr_Lo19b5b%!IfLWFTTGquFrBRVE#"k)\<;6ttG*&0h2CH
,sA^e5Vdal/cMp&tHc8i6g]AW`97h30a`78jil<92l,8]ACAiK9J3\c9FeGN9b)PAH`FtTmb%'
@7-D+AU$n329@4aJ%/WNocqu;1B*:fb8QIN4>CB*%rMX+ajZuq"UCCIRrM)m[Fd*;(:G0Qb!
h]A1K0D^isb"6oAr__$\]Ala,+5/,t3a>3F=^5u`5Ka2jO$c^=qO8NX:jZB@<WD>4>jTapmTT>
SXn"9+)1`=t:=qU0[ak:+YXH<6^^^\#%ii7.2h_Ra#[-J744$jJ'eL-e*APG$E9H(,0PSO!u
H^2b[_#@<sn6ujq2ViG\]A^Ghn4*DtYhK8Ld_B]AVX_4eQT_E(@MnfbO@`iX6'NN^H7p\RQg`L
nd_L6KA:WR]Ak!^+uqB(&p"<#E,AjbC9$n?CN0'&tpZZ?5]A?WFFu*EjiT5m2LBj?]AHn=b,fV'
f@A5!,@A7f#Y^JOLaqD>"?p<=jG7IWUT935,;Abo?q8qN*\e?@P>Nk6&Gj-p=@SmE:PFY.Jh
49TZBYt^'0>od1n7sH2P25.']AXEa4\%*LEU\9%2^'Lj^@))PXpA6?^7>$cP6EB<4qX.sf'..
a"D,4F(2b;rr7-DV+hd?XWdiuuX+pG*RX79o'9)mQg@'lBa5$m-HNnsYl)ZNlWZJf4+>gHZ7
7ndjOpSSWP2d+G[LAi7Y#Fh#c&%Mi;jTN;N$JIk'D;=l_a8l.gZYt$iVpfV!T#nt#]A]AChsE@
)7bZu+JhQ<l)0%*cdSgbd5tFm'NdS.c_MN`0>]AjK*HTs4/*uijisJ)'_`S)(d4AkfkJ<kUe/
j6Dkq1V`^u<-f&MgF[3et7lF0ih-jNSfWf7M,3`"2^@bC0Yep1uh3ItYQs`!`*ah0M\KT1R;
^BAe&eZ]A+oG:mcK56S3>pM?fM'9:MO=LlJB=k\bpIj$b5(@fOc3t8rcdj$T>-WciVBM#c8uC
kKH?XbjVO#EO-n>W3HZVAuX$5?em>Dr*2$cu!f6fu,KF"PuFsYI`e2+tZ(>rZ?$eOF6o[M@O
I0U(J:BG<*-Q?G&"B'l!7%`Ig,M>5Zc$D_J@BYVDB<[G9bE)B*\B]A^0.ZFlb!NA<!+Z2rl>V
u(V\J8@eB\l>.,,V:!]ATHQ(Q\RQnVjd="CR.07IhLfFo\h#ba=XKuC1Pg;CYiZ?7iE%'C!9q
Mr9Tofir31rrT<DL@hfE_+%5p#hs&?3S`sMd;aZ/Wqc2&_N$+DRY`PGDr_\?aB*pTndFd:lQ
,!Li8I>rkJGOX<(l\YbYh]A!^4FRO*WYeEDk9`!:2K9XVoEa;Y_@'UJ.!Qh-5afau3O'U%D:*
:^W$FDim^]A7;ilp<bk?Q>A>NBU=2tq=.)gWB-5GKioH"j>tjV2]A\?WVM-#DOmgp-Oik?faUp
jjuF^_';LF@:V(*fef^[q"ep8Pd0,^l8+NtYBio"*$I?H/J[!?/JX^ibnZ[MXVBJlTh"<=:*
'(Nf*3]A"S2M9'",#VJ_0j%[K;ra1-?YW[o,'>@l:A`BA<h\1\K7*?gb)2Baf/7)TI6a1&.l;
5;GrM-B@D7uf_t62r;2m!^/89$Fa8s0>tK`-cg,DDd=QU7%)'$hJT<99M*`H#R6kDS\O('`%
&AuANc,_u=r3-"Ddj)JW1(%uC(&B@%$+dk`$G?+<VW1Id3H-LWWXGi6+rtDUDili[(3N"/^?
H0"uF<B3BlD;?#%XlB\f\?G?Y.HZr#=6WaHhkUuA!ROhS\U<>PWer$4OH!lm(!MR0[Z1R73N
F_^-#\u1`%FbdiA:kt5,j&`I#("9St9!I?i(O5fY2%eiB\f*C@A3XN\r\BTl&A6aF7ddD-Y:
[]AQ?hl06=f1IoRAPeY=m>uo'E*P\dXY(!\gdlfc>:R'E$VZ*T+t^DoD7"EdHL8UD-=JpkJg&
IVac^<YB$DQI4F!4E=lr8=ko\>/aoN`>Kb:riCZ:pM:THj70:HBqimPU'#4)nnrRf0[^P=1g
)ER3ZrN79k\?jl\KF=beMdUeq2EsUK>q\)23!qU)7$^qBQcRD!+U5,`4H$-S`9[=5>:L]A4^M
=o(`EjU&D4kXYr_7JG7ioQm*#Pj;AE>u2HOScoh(r:M]AnrB[?Yhj[!C3G4ae`idTs7EO\(Tg
g?dX#eEqm+pl#[.i-nc1Nru<L"SX@f/\Z.2Fg?Xm7+%/):k4RLa0`fIO%)c8N3*tAmo4'1$I
K_NWqE4r^Q65LP.UA.2'At$\O,b?Y*,Cgj<5U`n6Hj_LbCSmFF,ot`jB6;dW@[>@4s3fn[3P
h7;Zl2S!7J+RqKWm6m(4ZYd%Kb>l'4.Hm`jODl;1EVQSBLs7,\YF!T+6MUI#0o4m72pU4,Xo
*N\N-TA0;/Mp%7CHSk%4>o%)keshjqP#`CMP<_e14Iu;%eT/$$EB`UQdM:Z#iY.(QP8n8MIS
Zt.t@&aR[":1N(BA6MaPL)c%+-%62=,I2?]A%Qg3c1LP)A6^->&iSK=*j!e3Yg]AE=u9>kWr9H
=n6A$[1TCR]ATkK5P@^\fTB#VMO;EM.^L11O*6^E=L<kB#!Q9/kc.ZDE"VMV?>Pu+9\[R%X/3
oh)rC?012N*YSoQ$]AWg.Vc&gIuZ<gU,Kl$Jj7N:Z1#W(V2i*\]A^pn5im\ZdM%tsM&o[lNl*[
ejn,h%RXhtI)a+%la'Pg)@$S:ePk3]AW`5;&Ffh@]AJ]AdN<5_MXg2=1f+rll&-,gVMl"5C>WHp
3?:kK[NO%n(c]AQ@&qpn?^1?tGgo(43)btQFQsR2q%st0QW>T'[spij/oXZkO5M0o9$u%5bMU
XdPP``*7`3#T*4g<U2=g?TP',YS?=ph<9nb&mKG'V#<jh!5lP"Q60mQ\OmJ'NXJcDYWQ=09K
1ka?bgJA7s\eJU_L\HT!E\LdU`QIsr5afkhm6q'3/AdA$*YI`b8FW#&eHF9F]AP)MrKPc<(-U
JhDPVOPK*bcmcLOFcg>Ma/k`KG_"fa\^HZW%5<#^L8kpm/2`;m7JV"o=bppVpK-lm-Bgq%V+
KnuN&84fW#lllNjaCk94BF]AQR,']AoXLI%3'&_]AQftDcP@Z;SJJMl.NfkoJ;@#VU*Rfph#!sJ
E`R@<%[O3rEC\L;uMbl+#*4#%aV>_Mip$DnApj^P1se8Idr5IATX:-0uVFlO`@AM9[()W,uQ
YO:eWJ'[;.qRj.cu*BRDM.I'WM/;DN("eboK,+(MH)j0-n1O%?NtgsL%75-r_tXAnhS%8K_G
>VZYJ$LP(Z%DE8;;jT_'\CO.gr9;im+2R?jnG\s4<ph>T1`9-ET+G.K#UT3;i#ruSl&eF1$f
dAdm3Nsj!P!ruK']A0DfjZB/,(UDIcqV)#"<qk!c!0eI)?5AK_`&DF8FXQD<QoGQ?f5`)IEpi
.Frp81Y049e]A8<%C\;?cm\;,2\Pe"^&kG!(Z8l>&d<g`R0W?*A<&-al8d^1tF^g-B2=LXY-q
PSgs@'k4%BISF:$b"E;fk?jJ.rN-e)M*7.K'eN&.pDB4#s:nt#&(I#O\"@Cf-k9DmS%Aj7LL
ojhq"R[HP',b":u?1W@)\L3`$.Y9p.YODo*QS.(Y/Wr5?riV8/G.f?g@dPID4X`uSq&NZ$I@
*s=3>M'FWjKHfWukF\DM$E55d_>]A(CKmi5?CIgh=)(Fb+)r*Jj"*AfUD(sM"YY^1U*r%E&A8
73!s2nhr"6sk&7-'.&MY)@i0Ig1,is`oQ<K$h]A:2kTqde5j=)63ff"^fcOlfDu3FUebG@V7s
<(2oE]A]A<6HgNP+lYD0pQ[[m$/MVM:".'G]AD&,n\u@ap%-1qeQB*1@YP51A-?)#AU$qMECeYA
<L/P>E,V#n+\ErjKA$"`1"D9>X+LUg&F$gZ;1bR.5'%hkrE)L7Bf?Se=25PF9n-Ta7.eScrU
8)s%qGS?AGrL-NQnAg3H,"I-C#!</U/8""aBc_;_:._6,l8EL<tj=-6>\SqhZ',KPI:n95I0
%$f+`m;/^e#3'iTPit\[n&TpcDK5JGV(LLpJ<Hh-e`u9\'WVj\gXhO5AJU.Ye^$+hj@iK_R)
V`SKiT&3eIC0(If"-_5PB+EL_25_&4%oYrM+5d?u0,m(hA;o$I-pu%KDHF68i?lM11tj,p'"
Yee9fcF^ZPE++I/fm7!32qa1n4q]APmrGd0ThmoG,Dh]AlM+no3adJ%?Lk07Wc+5d*c3rnIn;h
9PU1K%GFs)!B&(YMupmYF5[p)KU7mZ%S63XnIK5C=%H3lPn,9fQBbaS,Ni7L_di96:DuMD_:
huRDhqBK.3$R$'1_/F.L8o\h1$VZ%^^'l#OC8!Bs0<Cal:J>nN586cp88VCSN#N@V(X+sZuS
PKE*RjbQmDkZ$JEbf+/0oPL0sbpgC+BT!+oSH$oJ`2VMf2iVk6!pqO/s1^;4Dr*_G4I8$Wl7
>;%JSQ1%,-[d!NORlS)=qh_.[&GrK):fl9[WbH&Q^B=7@c?^l1YU-HY//YZlP*9Na%[f$#)A
PHn8VTD*c_drZ:i:\*XKe#;E/A1\38<Xm1#rb[+r=nB_iF9bKUG#3)a@/W^3/T4#4QTD]A+#!
\(E:5is2rr36!DGtK]A>Z3AqG?d$4[.c!G(L?8L)d632ZUGI1Vb%_7P/e9Q`Xd[\-9JOE5#1r
$j-+;$OlI9]AsSK>-=Q8!^i1[YE&)PPuZs.h)?ru.G\@[&quJ-u;9G'nB/Z2tn:KnX*kW9*eO
4/,SXWtJ5-M@'VVrM4cJ4)?bK:g_`PBGPTm:r*%8G=,!?DpoI&=_[lb-&!VmaE)1KRp'jYq4
2U4qMqMV_+(3/f:@`VN5gR+2bnm6R5^7B)CdUYWIeTB1?KI*[%_q9M&Z]AHJ5[:;P(KjU[7*r
C*B//lLLnLmK\B8XY5Wi'H?^O.G]AU'3)p8+gah=\;k482k7G]AVVFa"38WX$M"R*R%B^Qn(K2
BhZbD^lRVX-@(glZ(:AW:@'Pfk$-nFJ`&X3q*nlbXP^X[oAqKFFMEg,%%`(QQOP4hnj#XS^D
,_H?W#/R6W1n+,ic8*#H=^&C:*-85/TM4sk<J.Zb1/P=Vu#;\\r%mGC>E,)H0Job-LUWO.K`
@>nqpam420Y]AOWQ+#<PIJW'PQD58rr$qDD0A(7#X:)lRJf,/CNl5K2OjXaZ09#G#iY+0B3"\
2D=aP1K,Qs-g%2Uo:0^S.dEeH&/Nhk>@QV:Pc+*;&:h!t/:Ik+<Nr!X%Tk;E7<cUt(*qHpC`
R%[HR=9[QM.V$P5&)Je1N)WJ<1S"ZDPPSc.0>dlUQo9f!.E@<?Rfi4MsjHnY$P5P)m<BL`)C
(7.">J(!oCS8oK]Annu=iqR>q`UcY`Vs&_m0SGiX-cBG2(_+!SWn1(;Hh'+jaRUm1i%[0'qGA
oN%LZ(!id`;`[dd!80%Hd@XcG<)ci.(>@-B!ZVSE]A*GNk_pN[s2*NhNm#,0h0;W5TNVR,X&T
&nUBOr^%6mFYF:WTuA@#BZZjt28=CMTpBg=%%%1:aD3d!f8'?r7N`$Ar:/u5AU8u4"=VAFee
j2r&.*M3(jqjW)YS5Inm'%E424C1I.%_YRj<#DW)d<tJAK,t;Bg5S+CKt;VesDnZpFmO#?.k
I'`"`O7FMm\[&n0%qN\i4_"60/=M]A.e[?f?r=R#8l[X2i2:\Xc2*5!Q4c"([+YQ,$O2N3?ck
_,%Q`$(X@I(]Af20&9^E`M'hqc\Jr4ZAo*OUm/2DpSuVciXnr2b57gh[?:=81g)IUn"<F&KO9
AAdUnk$KpOZGUaM`kB;=DO'E/ms/cU/\c%cr,.i#/@d0d/e4=RArP\*Kk2F6A:"KTr.rD1uh
$,.ueSc2E!Q1XOco+W[<=(p]Af&1+OcGa#0VFrId!,s#n0G71reJn4=EW_Zb!A_OI6m+jW63G
0o5=5TTjp/!GU2ERqd1%N,V'V'E(9`G`#-beSj-XpLf_TrQ:IJWB%Ptau2bEOeY(S_Y>nD%h
bX:GO)#tY@s.7%9N8mo*#Y9>kn[##G31XH$,en\^/TJLbV^>_9$I%WrmFjAE5C0r)nm=1H6!
bqoM(WEUVk<a.';_KV0AQUHW*P0g`(:`)pTo>`]Aa;Rr9U[7i6(DJnnn$5B%C5>1s&q%J+&+J
:U?[b/r:TW",fpnnVaSi-!p6PEX0<0o!YZ\n_K@R>4\L<_0E^LI1!&<GqnoD3lfcbjib+?3(
-Hm^Q&D,iPXXMX&`&*>]AYk\5aIVXpfG;D6$6M138dV2*>L6fuULLP$#_[L$NOmg%2cC>Vt[u
/4scYH?d[Lj]A'Eg4c=]A"))$Q-GE93YrXk=S!7PFpR1AdjplUoro3MTjGWWLuFKE;s/^;(]AWS
<gC9B[s0I"Tj-IgaO+JL]AJF\n/d$#G*>:qL:&hNOm?`Y\g!T@UW>7bXhL7]AA9\d(j1`ut&nY
@i2?@uNU!1^"hDTrA,,='TTX-9\+Bd"b5;G+:\3:e?!L8j9FrN&L+>[1>atYO99ULT7383Eq
P*E[E:acZJEgZp+1!>aDi1b`iiVeq!$0eH&0mktB+aiGIl"WLiOlpV2-^BtMeLfa<=^Zo58d
K9c%ukC&2Wf!3X1Yi=+n!s+3O!`:mXI=X%XVfsMfNiL9rO!I?URpUdEZh.jZ50?f6!sP#G*C
AIJ$&`P2/Zf1[aOepbkcE$4\CZNV&r;KR=Ck1l[rgU"N[<XL.9T:pm;;rt7g4AUHXT5qepRs
7oO"+;Ft;MrQodRPo[,k)CN<W3AGNZT)U35SA!"$a*)2U<<DM@qDaP*,O'f)gH"j0h:RWFDN
YRa!ms2$Q%X$Go/+eVjDc:K*6QsPR$b>*L$UQ$1>jhbOL]AT7YX2BTRF.sF1k5nQbcHiaqhXa
h/5Kf>UZ`'kfZO;G%fo0Q;(?'U!UBgs?Q0Y`Zr7H2&/d_%N>+mVI\!EP=7X?-Z\-lX8(ET/.
H-N.;e9+;mdL"CXe4CX3Gsp6lj(>^#3NLXQs"SuW)68I<jZdI;YV[&("K3\aVt]ABB3U?\d5=
f*Q^cg^5m:A$VGa4G),cZn\n)OB/c?<3;+l]A4-/kYAs!(:5MF61gSZPT[e9I5npLF`#2!:4]A
Ph7.kH1oB9@[4:InodU(L05J;*7->8=R4eX$i=uWbAU]Ar0Ip3`S'A[1VY?L4c6`cPh%#(R3@
9D=,Td8Q;.qq>!$8rPpk.Zk7&Xn*idh3P:]AAfTn9-6c756@-B(]A<93\c(oRqr[Mg_'h-_W&P
VWk>:q\4,#D9)72F]A[.<9-:Y(X-S/'QR0\onN0Hd5oX9_OWYX[PIG:DH<!!ECTQ&M*M.D@f"
iRW/eg)^5?c:/?sZL'c8#-EH\TWhZU8+Md14/fe#Y?M"a]AfJCU1n$-gl,l!D-Y+#q$p=6WLW
q`aL$cWqMIpF&Z0GUE-Km&MH5B6ekHKBT2Q^E[Ue11@?W3O:l3i@fir_A!NtdM]AD'rKh1/ot
+[`L*4$WWu7@n+Eh!;!/**1oW1es!ld-O!JBT\bl4K8=pS@J0G%pu^GSo796_"WrdJ(*#(QC
L1&X+oLZsVW+5a5'<@@d[QWj-`O<P=*[Ci3>\$J[Iq=Md>TOM(H%ZJ?;.P5C@6'UHliD,,33
ieC\SZp:^)Ha>Z?lU?;t#uK96&9phs%l,Cq%Z97BIE3r:VZWp[J_L+7g#rWKh1"A9o!I>U:*
=Z64a%&`p"<5HR@3>u@%PWL9-DKG?.le8fAgX,.^H27-^*l`Eona-2KiGFiklglsjon!Q\ON
&nh,^*4t_^B+YqP"pSq<H;_\^ESV!;K`U0"urS1+,!G$VpmSRS5"Ke0o\9W[R*,G1P<H^\`h
[/+sZd7M@S5+#L+Zq4E&PeG8GVi6LiTel9P_e(TYr^D.FTcSEXP3lJL!UQFF]A@ZJGG$3UVMh
]A.#ans<^OgXU09"9TuoEW7>A!0VFiqA#,CI]A5q=$K?u5;1oY7p-g3S(B1Rk!iVTn_RPX1hg-
;gGUJ(5EC0WkE'2+h5AG3rrAtDTOD*]AmkN/2XOHVs&S$,lJE.5Wq(#_5=/jF?VVee\MP+B]AV
g'9OpX/WdLLMLi)g_T,UH[c>Ueq45@q1`I69^eaX6#utIN$ba[f32V>U/">dkro/C>u(L%KU
?UY\]AcXq?[T0cAXu012h#);WbYFRG1bNO"gCGt#gsMd,3.dZpq,2lfTTV0aka!?,j<X)8lWM
b8fb%Z2ZZVu?IoHO$1FBd.#id-bhKbiRPo>2#n,Hs)&9Z)Uok)s"5i&WHIfm,OcG"!=_4EF$
B83X'*k[6pLGk7Rd:'3$%OG5Z%H]AkN`K(u)\mqSmqJtBUo4_G\23`2GareTX)#QLG&:#;C[]A
3o8e1nTZ&9I?0a9hcH2`rd.'p(&EZEc-&I!VZhgtqXhFmbYa8PP-L'*AIg*h!?KcbB`EV^(,
V[2]A`Wl8jCWo&m$mVB2!&D$Ca3eIu6iV026bM^Y#!ab<%G80YSF2%R$f%L`7Vq*gP![@80pg
?&!;(-DJQ0(#G7usZH$9E`*YbTWChQShgcWF_#iV;uMB2?$F(tA7GS='C)hY,[:$8TSK!<%@
3mS)/T^^&Ya?N6XVB)VIcHcK+%"b(*53O@6n=eE^?WV`M"G-4i<MB86UN-N%=)@&4]AikM;Kc
!&Oq@?mFiS1cI^W3U[nc2e$*85VGgCkj9dh/DfV!^g>k$dbeJm\0QV$mobmWCm3oTsM*ERFV
4Rgp+DrS%f/=m*7`4n#'Hu:CJ'fc$dM*)E-G>''2XJU\4K9p]A!MhMBn?mTqHheE8,SRAM*,1
$]ADS`(UX`k^UZ@5nY<t;NR``q[V=)^S2ASZdFT6)GaKA![SkJim2C%GRMsNC5_2Y6?paenMk
d_-GHWf05,1:3Y6I!NYtYgK5Fck&WNc**e/C"4Oa@Oig/>(+q5*H1fCMW15*sULd.@BbGL*1
7+aF+o/`%h8jGKF:)r@tGf:s=A)d`/=g5+R;3nX.P"(\\!%HAo:'oQ+uF"n@]AA]A1e%agma:*
@ErmPS6DR^HuauD03fVK\h2/$1L0;X9;#n!]ADK><#,N\l\Yk'cBZ&<LeO815\u-(_QItK?Z+
\f_TSdiVK@!;jZ+e1kc/m6:FKc%a!nAXo>&;C5dXg+M)5O_a\M@oifOhY/rG#"08X[Ig?u,4
WL]AW1qrHkOW/jH:s5qmd43a[LF)9m(Z`>5Y6rK"jl.PAD0'KkLS=Er>VG(o[Gg0kpl7PH.ot
tq474N2,)BB/,NqW)t&GO[G^QGVrm9;t:lMo[P6J,DP@VO_&nN``A7"+54B$^ds+#7HG,(DM
gA2(^N_TGBpXo7b21q=ae4KciKA17f^!Q<X,q9?W@n/JT!!^m,Zj[qLAgqPW51B;D[0gnnjL
gmcPnB#@6JOJbJaMQD\3Y9Ra2l:%nVMIAqRbciub9-9-[:dudL^=0U-uI4)^iV*e6D#8(]Ar@
rqS$cRNK3J<(8"S(MlqX?L%B1!b_:lDD;n*q&ABT\Kf;O;0DA'-P,T;>CB8ZbP_P&^>bE$o)
+W/7\oP30Qh"<nLE>*Tdh:L9FH$q28T07*;B#K[O5)AI_S%U,.V^?^!MCUg_HR#k.,$Ws1B4
\\M.LG53Go9haOrZRZ!Ik-AN4?ot9Rp=(I)9@Z:.I2b4<T#=/=q6WDArF%0m$B8T*gA\OIML
M!%oQ6!b1i!PUP9JJ(*8\p"*TX0U!p0%Us?n)9Kq]A!B$jI:!hL[a\iUlgeer\,.$mlfqVrI)
KPe`WdL`9b(W!:ndYo/dpF&8@*`l*gK!-u4QH:U(IW=K?E5;+J3J/U:XsT[]AX4m4EcT8H]A8u
4Y_k#pW_.MLJ"i!h.Fsi:9BFB.TcLta1YMo\W$/<4$]ACeC_FR$1)^pF3DYSHn,b_0,BZ>\9/
.enu4)O,>gCFGORcXP^#Gl6WY&P@bQfnHiuWb;6B@o@>sRQ?ei-Ai9D;XM$So=oT,,TIc.lC
2EM\&/.e#)TKb:I5#9!L^C@1kfSji2B(oNE1cjqX,>6#3OcH$k9!SfE=>/n+qG<b3DEhcmIT
5Sk:>\R5:--D4O1[m4,mj9ck<-BsKG["ggp3CnQbtK1SDkQGo0>ju2Dn0pO0-F=mE!l%7r'P
5&,(2A0@@>&gKJr:F6?VW18lfB_sX8NL^G&5=2OTD*lqC&Q)7UHplhdoL&e0'LY@!B@K/[7e
;M1pVoSZYTFVk-Crc%MGd!!$S:&r8PN!"I:e@FN.*EA:mdc5jA9\^<r9q<Z!dWGT[F(iE9R_
@`jIr#s[FtCQIh40gr,CYrqs!kj=WgrTPkEVI_taT!pZFVP1]Au1#<_!06GN3HFZtSTf`B(Ic
\'F*ni,'JCI>BU8e`t7,FMK2Ti^/oNQ"$bS_Gj@m_H365tBGC!'hU%>YPIXAsshp5AkO<<>e
qp]A\T<m^>&TB^@0.,Yap$5TWpF^$e35nO%MT1[S[Xg^L#]AKZ*8&687Cr[!IS]AI3nN1ia-WV1
&C`!>-l`t6C_6fX3iVf]A?jF$GOdGI(O?u23"Ish]A^_7[]A]AUA79(_nohV:Y+(J!b;hDCCQ\D`
E-]AqNc#1HC_uc<>[gj*,e%-u7r:+agS8EL+JQ!>7G\n+K`l;"!IoOQ4@jIXB'FM!XNdrqjGI
%K4nN3sEln?-5tb_n7YIo!79UB<!uR^jW9%)_qOg`']AWed)4Drf@[K1<p+3OQ"%+J+8u1'`<
?.[QB9#4ZTumc4$lIc<BF8+6i@fL\noc),6C1Xe<ut\<@!:#J'\JI@EX^lhb#8@lg@a#1Vq@
9gHOb\X=+C!Y$?iZE5*L/fnD0DQ!gLl(Nk$`"fBd=,/8tS9S6;?CBHY:A*)RTY]AF%%3dcoB;
I6LF$kFLeM#d95!bU#$c`r#ZU+_?J2#1^]A0+ZR9cb=&a<D7+ccir,dUa?^%NdY?<iVbn-9+P
TuG+-tARGp61,NAa0b+jLcrtRg,kt4r(5'\nZ)\b[hoR.cgf,r<,cXs_H_tF8nZS"8^U,.a'
A5]A\T>0&`cP9,OD.^$6Dd-TKeDQ>9YHgNJC2Q'EeW<R)Or]A*';#OO$(qd1Eh:4#b+B6YND@K
p1[]A4h2(MFFH7&**S6D52I/-DRueI:I_D,-6!RjS\!#qc*Qn"iOFq-CGT>AEbo(PGb^L9(ZW
l^#)67#k(<in?;F(k8!q'_^XOd36hX`D0$N-kMLeHGa,ums/4ZR+p0%ha*9l=-C'O)mPB\H:
lLk0Er`PcB8NGM4NBm]A8,JufNacoXPGgq9;tXR"kV!2uC+b?aVgs!^-@f/IEQJ3EcIWHa\&k
!`V"jh`+8XdP<Y''2YBkc?G1RN_rlpO*PlggpZEiLPA?5VGG;'lpjO"]AMkNk``q'ZL165t_I
OhqOrJH@pbiF@u>qWE?/ULOd).?(C!OVGDpZm-j;IoJMFLNX^:K^#doceZYb')`dLAQD[$-@
ejucaH9ss#YZDFWV"d+"np(:&b1XG-o!EoDl:?/Ii=&A1p$V+Vde`/:_TJRi(G-g`o*M)IEK
:#qJB/l9fU;mUT8NZ+Qcl*jb6qShf?^(3B.Z56LbE%?;j^NB>@.4QK&oeF6?f.b0B5TC\[17
?Wb)i$f2h3-C"Mk>i$JMkXUW<7"6r-+"6Gk1phW[EO"C.U]A02S]AOMJG2%LU%h3n@_[s7$_^L
@&BL]A&1<U4RJ:Aa"UMb)X<9n[`3K>KP3NO'+a/"W,Z(V48H;N6YmJ#;>-B'XZ22/Ou!:FG:V
aS5^s+GD3@522=@4r9:l&?gS+h5^cF^o6-S5^prC]AT.8%dD^_U.]Aoo.hg+uJdN,[]AT&)RSS$
(@5K"V%;_&]A!7Hob5j2(#rP54:@lnF9,h2cfSF[stsVY?3Jc0\]ANlg<0bdIBp)a1lP5o&.rq
"r0:*pc-\7!4u&<REnR_V_>''sY&j2=gh4;G*>t`+s/.GmMQcC&RY<i3Xc?Fu46\"2XKZ3h[
VacBd]AmXNl.EH3FE6s0q`F\'J*5SXB$H6V0qM6"WbOXp<;.abX`p@nlFX[3*`FNTo.o@h$[0
>^;&lB8e8m;n[@I[*#[@Lr#@=sMQ3k/&-/4p0ATpnaVn?kZrn:e4^9Trm;67foi'*!Gr%>PI
^V^fOLgKrQLtOse88dbU%O7K>?lIqbcb<+LI)5*hJNP_>K49Pq[O]A\mCOEC+=P\E!&"bPSGm
nNg,U<gEqHEX*lr(/o/N0:a<<_H_ZM0uHM3(`f]Ad;]At9Z*]Aqf^qsaKaU#TcpFb4PV<gKU*9l
@gOSg@L[8U)%l<Dpk$-GA_[$F<[MXJ&_;FY*W8kct:.3oY1L#Xer%R<r6_m1Ys';t?cZuR21
E=0Kg]Ag,5F`rR:A05gIYKj]A+AI@95+kT;65c:pdInkgR)MTnC7:Hn]ADYp@9rZ;urVHcU)B!8
t3qKUG2#pfb(mnMY6CRcJ[i\Mc$<2Y$Ki^-&W4me4#XPM2'&7f4G<]A.F]Af%:f^0L0:q^c/s_
^_&J[?M>!T:bgiR9q@UU'q[aQ5D->44e"nZp`.Q@DM7!ZZ\9N2:RXB)F'omU@c-0]AoV6d,>a
G%CNTPGR1jEBLW58Zi4g^X+ep?o44I7R6nJ!u"3]AldB8I[rGS/nju0TT>k0(&1?"d2>[1NBj
kg&WAjqB4H?p1E@sX0iVjpHuu2IP5(1_aj^8$2g!UpW;h&NGIFn'+/MIgt[_95,UOEf2`qG3
)'NB0-6DY3uF8r-.mLcSW9br"pH.-ik$ER[B9:[_^5>801;r=S\]AZJ!NO80c)Z-LN=,0YPgA
r3c[CY%3[\3h`J5I[cO^Mb6U52'3;acTG.\tDP?T'6T&.AZAs`8A*&1u><8;9TZl%NAUsJ74
c1=ACg;-BN?Gb4gD78V#[U'7lH#a<"\&rQ_;\bVpl"2A&SD2A0T0.u6q:AXO;$VG10?tc]AoE
NfTI&5=85`u5J=>HHkT0;JN<8mR8:dhi2_/CX))C,9/%>r=GOo&4!L+Cr=rUUaMiGOeP\a@"
^M*$LrLS*LK^ogs+^6]A76Hi;`oRF%$K\O;?dG\ESXL#t#$,j:=8[FL1_bZAAsHD[0!B_(4eh
s[Q+GPn\g_`AodIh,A:*HFH;l[Y/>]AS@-C$gGc@LY%"[Y`6c(_pi&:a[3IK7d=G9Nr%gR]ASh
#X$maE9FJjHBBFe'1XOhE"[0R:^NDUrc)c?jpi=pd:fq;2@Gc4C&XSk'#p_K)GW#^CXdG-gQ
.c<Q]A]A;d^$E'FOheVQb_-'\DWE1$a>cosjIr;7PAHie8is/JsYo35o.6+XBeN-j#Z$u#tbng
L"WXZ-,=QIk#!A5k.VIZ1;VpOipO-S0qQ58WRt&I"1?.]Am?KX6bJI7nCMF86O.RSDlPB.1;*
2I;GO(LdI<rKhJCo!VeH9T?mTPjCAKqo[QbD"Gc=Kp'Hf'i>jfoXF!E44fNVZ--O?)`0WoX=
k*$RnOED9*jdNXQdGX5`rra7Z`)U%Xio>VXA4cuLW?FSlR,Hmj.jmn;q4+6GipA+M_Mk9c`J
s5^_Hu&X4RZp&4,EZi+m[]A^At!Xg$.,WJ!oP&6Kip@(:u_YCNS_'+.Zbc0nCZ/f7%D);cn]AB
]A^t;Sfa\<=g3;D3f/bc5/;Cr,CIS9oc#ePjW(27/X5<qGpWVN+QmZ-CQ=<)@6pV-.H8cSCl^
>FCEU6tH0!g-7S(JEs*+<lFdD%o9e"!L#q\6JZBofHiGg__7SZ"IV7QL\*4=KKeFP1!P#4=&
H@hX#m_E]Ans4,nl!\\`b!7ra'pBh'q==JZgI4HG2b=u_'8:1G<)fjaH[d9R-/$'^&Rg6-FD&
WM0L>5S>hBnPokFgsg<[13A.e8apjq,;!S/edjjH;Z>gId:It'arHDYPf\j864Us9F5indH2
9Yc,r&p`g7P##T,hW[OB:D(r/h]AXLT)/7^@)79[5>t&Qe(3HJ(bUS.9_+(65uVBupPSKA<rD
#KB?]A;(pY;0qs-\`H%2)?+DT9jl.BuO]ACJi#F%eD9=PLPbK3?>I/C-\>J+=gOU7n`b()Y]A8]A
2BF[7jg]AS>,RbRq-n=)K#M!b#EWa.8k2V`!"\)7;Hlc@"P`2X'lb?@GA*4@Dt+P/jqcJq!Y'
BJ>hZ2NpD$sDJNd[W&<gYgmNZVk*&1pU(H!L=.Ygkol`?5f/AcKNWs9K5,hJ$Q.)6m]A1)LTM
?!\sQYkLL>Q"G/":A5!X<m%%b`^YFRuBU`mKk=r`IV`WmZF-4AO\g&VmNG_I@C4*or*32nY#
,W?SW+D?VAtKi^7JsbM9#>k,[7J58s'<r^%Y@7(lZE;:gFiD$M)KXJR3#qq]A(:=H#-^@A9N$
rQ;JSkhE#1)5S!TH.$k)K!jFi0:AC$)b&*a`8Md-Ddj"I8q2Gbj1M8kZlrMJQ*Ci'nAsMM((
kJc!!N=/(5tm'Ol!"Ca5@l&SSc+a\d2>rQh_acmCJckft:grH4qGJnn_B.F\J=*C]A'dWaA[\
3cH!Qrgog8"a>$8]A3kMp0]AW]AYDg,9Yl.T*bn9)/I#KD*dQ=?Lj6[_K4W(&,K@+VGMuTK!/QI
/jLs=gU?f>"2BdkV@.aeN;":geWNN8(NgJW+!V!V'YL4ZjbYZ,JR_S>fk%!^VgY;(6/dra4"
7t#e[lWp&\1l6M6<4kq-R6`F>$Qrn0sBi"PCi^?V8]AluL*>2ckhlG:c'T8V?^hl1Zm?9RYr$
O*MX(T2]ALd*.BD]AMf\Z#Pa9pSpa8\-"KGdiT1#PFF.IXCV:k:,SSmRebl@'SH%M$5Sr)#^/'
)G0.))Yf.#@6LS(Ti/;]A*)\P?W3#7r_#Sa;k2;:mY*81PpAaXJeZXcf0;HiIXZlf$h5:#.g_
S.a<@qVFBNsnF=n)r)j5jbQ8en+<POse+gql.#lGhgk!$uCq@9]AT"FlBam"NH-HqGYdGe1nb
-&7+'_\X32Vra<Cn)Is7OuaAAc+#eps\i1SZ2MbUL%K>W$Mr;UPckU/^ccg-Kp&@BQpNK1dg
lGL6$'WVTD'7fm*HYe8E<YV6^\qV.5nf)8G7$Mefo-O[]A-aqQoMHNoXZ%ZEON'Il[/Z(]A/'5
RHF93O9OZ'03K0[9U??SE^r[)l`BEbKRDpT<GQ,J*6g7:B%d+9/=b71c8caY%6q`5]Ab%O':-
>*u]A[)JV>;Uh7#KOGqKo(Zk[-:<86YC:GUa$dU[QL$B38P7qTA^ag"G^[G_DYIPRqJR>j88H
F3%.</`[ncDWP-qK+P.q;+:1>GUA_+(oXFG>ibf]AA]A*.*l3L,BcD>A%i=Z:Kbe)006R?<'r4
s*-jA#IeQi5lXjIOeR,p?@p!QkhQ:cY)^?YjkSE(nD2DgKL'9@DZnL*bq^?kH$5]A5fm!q!g[
?XfY7sWiaA0Wju*Z5H8E,fB:$7J<=69N]A!fF"oQoIYA?60an6BSBR^7[NaV1/,du"(]AI5%gO
6uAQff\^Mof`iHS>_9gUOLB2l3l=I(KArKSou'Y<=3dNp?TI=ld)P=r<gSmI$jZ:+dt`!VBt
o'L\.X^sl+tk!"%bTb\`Ai:B6)K'IYl'eeXkk5ZSjANcVYHF.G:6B:?"AXT69@mr8a<b%d!q
L2\0Tu6t(_\RoLM5a@n`+i89jcZ1#N#)E4hJH#KtsT8Ih%\#L8;ZO.3K.5D9YT-&I^_94A?d
bZJ2fqirT?X1'IGDC5>M@T%,V5H>FeXmjd2JS>B/LLce44Rl28(Qi^]AH.lCCFA4Uo\E]AA8%,
<MV!KBLWdI=]Aj]A-BL3]AQtZVdDNJ\t+N86%_O"\_p>69NschkS!I?dST/=\g')ZNDDV9-Ri[)
(,[``=RrP(e)*GD+OaPU;Fs\NG@ZTK\#EXFqVOY[+LF"P;u8]APF[De_O0l?tGP(2-)I.2?mo
ao&%Q,;UO[>IY8=-<Ll=.CV0(.EQ&=1':8=>fFY1FYaLBj/an`^?T]Ac*'':Tefh.1&YgQDnr
,B2N7[3-o]A[hfjsu2W;`V?5\c7?0T$3`h'L6a3Pr[7MgJTgt3mm=<3`I"c8%rd8h2,k)tW-a
n@L]AXH<S<Dlh]AA"i3e[hq>`YS=PVfE9),g8m?OX,d'8=0t!W5)3'Z+DG^-kFMehJB]AlaMSpk
i_HG+:L*imP>cOWgLD#X..]A9Ze0E''dXr@=)=kaFkAjX?4nZXZd64n3`5?2gk16bdsm9uNaY
"?k+$E]AdfRl<quEF')>Q,O8na4Te2jf;:5`]AKP#@mWI7D75FjWOg`O+mDFFd\b1tkKD3"<9f
4!u<gB&a<l`L2E5BmDr52HSG]A'd`SR4"Fj7d'U@q9D4R2q"?n%&[hDWi0i"1d.okQUc36f?4
"=9E:N14";Kpfp_O*B"dj(W3Zm2LHp'UV?8X\GmU`l#4q)rJSbo+u!nj5<1E35S;CsLY)2Al
,H\o&-A0"5@>gZ76K@XL+E7VC#e;ee825O/j8SjG4Vu>11lX<LB"9&=qTLU48GG/)fIZ+;3G
]AqV1#=^a0BmB".bM01/_661Z2Bb;cJ;+TDUskI0U8b\Du?M"d0'7Cf:Pi>Qc2SFDg]A;kc`!/
OZDAuP\%c$G.qmoCA1qsA-T(G+#&(!2d@DOmY9nD=HC&N^1V[Mai:tDrOq&p.!qNN:0Ga#do
#l9=P=dRkXJY!'Za6nIe:u.[Fm=R^u%bGHgZr4khtK8iAtc24;\4&:T7fMY\_r#7OaXeEQF&
)DG6Q*'Sr0IKjHHs"4[BndAX6<d[cN_V/f0op7[0q%<s=X8KIE?0W6`_jX9YI0nsg]ARNQNpr
2-_pI4u/99mnUSR/sq([ZIVe]A^F.dec/'A5[3+eogSR[9/((K]A%=9E&5ej`LMrPJ&\;b&@c&
u.i)QD_Wagt4*&4M%F7HgH#BfdP8i-8GU02cFcbA4BGAZ.s`0$@abnHECb$1*ZC"i2^fXs:P
^(VPrgE<Mf!@+[d1N8%!.Xr3qV$Whk.n&bA&1+)o7V8n^3m&TLg!)D,DIg-dB-15SDf_+C=+
:6A@dq^'&:&(f8;m.0:(,T_MuSC+@$2I<f;0"DnY8DK*LJ2)=>GY2/@VDF;832N`.1(ieSoQ
IUHSjYLTq0)6tofE4CNm>=;C_3V3f]ALFZc+(.'ar.*N-0'Nfj)'s**KMB'iY1DQa+*^*0u]A[
g-3c'9$u`Q'4[gc;q+tfOe88Wok9Skn`7K#clE#76s,$P>F',?G@:sK8m9cT5jHj&S9]A"6J,
b"fLWc8LRu;0!ME*s!oV&,S%V-BS.k!(DkpH2_dSg-15)s4+N?AhLP=;0CN\8CnGp/GCu>B`
p,r01_dLl4;aftnkAj.<U*S$TW'LA"-KMdW59la!r(UkH'5`dn[QVqX(ks-)f`.u+aU!JYO-
&tBf_s3dpI]ATAooKVkE5jiqZVN/cM7)Fg8fcD:X<:J]AVn=j2cj,Eh?jk\o*TkKf)W8%W+_dB
E(oAbST5/"b,d'tgT/%\l\ufb9Qh*GKDC/$l14+o-!"GWF$dpJh)\>!LF?S`Slk+ehT+$haQ
n,Sc]AOPtM6:EnaR*N@8-0V.RkI-MOCjA7hN!>DigU6P(g]AJ,?TpqCB,kQ2?>@=qR29#qYcBF
nZ.-2u"R#"d,(l23S-q=:-o3,B6L@oJ[Ti'3g:uFdnm_j^+OdrY$_Sf\Y[Mn-<J"rP8B&Up7
TYNOpZ1q$"1u<'Dn$7pd`10p[miK8!-F4>Laau8%n!X7JfM>:HqO:fse$^'IiMOV(fJP(/i%
Vj*E?O=8<.OhP9W-Y1;n&1M106$M5BeJMBXjT4I$Tk0KsLY!rL#kSd3LffQ8"8#Du,uXoRB>
h%C?.9ahg]A'l<dSTrk(/ADJa=1WX<$f#%j1aeBDd`T"-+c]Am8Z'>u0&JEFLI>osdF(&Ya6]AC
u1q3A(deoj+h`bH0``>pA5Z,\[P0Q0"3e*TgCf]Aq,^/CF%[R/:\pL2C)keT?_eIE\K?6@I^b
@'N+`h>H@!==K0hAUK8W39;j.[,^!>c+Q[M".5[k]Af__0&UqGCS0[7;FB3MWYOhT_:Rg25kT
_fpe#XhnI!]AT)C;!QGlLhiKJP=<pm$RgMA56Fc6.$mBWqMaiFC@KOQZ-/jIB\1E1'd@5`Gi1
FJcm7UIig<$bMYWpkq?I]ALMEqEGR+;PeQ+q!qr5?DrtaJLeiB*#k5fj3Z"gsOs.1EV:'ER6f
:6i)(l9UgmZB$M+@b*t1h<%]A/M.5'/*eD!"C4)[<P>rLf/0ii62O>/H)d>p(XJ"Y:er9g7@%
5j>)81n>8JAR;:!\#C1n222&c'\Mc-S<ZS_\e@bMCc6?[g4dT3rH@`@FP&:qQSOQIb!-\<ll
E)mBp%S#^XTm@X`H":115f2<^5!Z!=3eS>Q;aY85&d6>)"K!g73IT8SWRb8gEHm`U3)iRM8(
.k0oLBt.a??X$PUC_(Uc0_ACEI?oBAl?92P=(_k^"_Bg#/33*GEGE:@_'LfNFQ"GBfGL;'HZ
F7AoMI4=jhR)eN&*)P$*-IVU00ClIguj2fc0['[IJ=l2a=r4%2nT_8)VJY;UP@I3U`-:I$!'
Qp2'i-ea2([%i2h3*"Zsj8R^mMaQL3t$=AmpMfkf2Lu\`2\%33%Lo\-=%3nPLQ:,<rHE@s?U
c<^*^>r&6--'80>9$%3`DfW%V7.OIdGN?a%8W2jR3Spqb_dHrh3gI.D*2H%:UZ`mMECf4^Ek
"KZ4)/#9r$uXcM#sWOqGE07i7`s]A,*CjDhbCD4<$#!V._$QQJsA:QCbTIE2@po(dXDhnM,=e
M'L(Y+e!_]A<P]AYsOl61,(h)'n>96J-!qof:"l/9J*72Ba1*WC::L`?JWubT;77u'//6"k3Qf
SX1L9Zo:`3BKkZ3s;MW[JFEXQ2\KnpY1IhTeP,4`VY5+F^Ckl^(]A?/+f0Xqet\6/>#.mm36*
:^S'*-3i_Hj2rB"rrsaNL0#CFb'rik3_I7hTbTo.(b_N=M[5[_^BoO9>mEJSD,3tpQ-8soO[
,Z$$&I+,"<dO^CjKjrC]A8Q)fZFWe[o@7,rbca']AXSZF(*EG]A3d5rN+IXB>#b/W11[(o!n\]A_
3MT)U['ZHO4(MX4b5/$AC(?s#U6I=q``\#X<k;ahHWLo^s[5N!3SZDJ`s)tXj=;lX"a(5TBX
$?WAHOpr9pQ"b%p::HQ(*M(7/^A`+SS>_C6U<^\Md?<F!VMtg3)J3ni*>E.]A[T'H'9]Ao4'^A
9%*YajZN?+k18Pko?EZA0^G7@B3.M,UlU\g]AX7gfAacX&ufO))"*Ir)SuGNi_k0G+3_>C*'g
4r]A=2>p\>1ej_jg@=h:/5fZ(%Ue,%:_J%+[BS`->caX?-Fr510]Ap>RR"k3bQKT\K0"ZR%-?S
\48k]A/_U"?R"9@-NID+2.ksp9ResU?P9mHk%9(Sfq"?#^:H0Jli#E^"`X,mHiUPD[.CjlbLo
F$\;Gfohg2_1]AZ&&+csN9ppX5b#p"gX[`4T\14T@N<gZRcQ'6h'H&A-$JO5G7H23t5!FMFl[
P(m+XD[-Q+afe^[%%`QF<OZ,%/g)sH^Od$h%cCg8#%7'qJTLKl@Y7hI,+eZ<esPH<ooN\T;2
;)0Y^O07V's\L>8<McoH!?c)SNU@\3FRIk7qN_O,[hHZ/hB8CJHI:SAbuN`p?d1m*@^t,]A(O
TnKmBoQ48q4]AqJToV0E/2%$Z(Y`N#UiqrK:U?Zbb!kTsQfg`L9j1+flJ%9RqGl(0Q.>fjM@:
LCS9GY%86FF:%\Z+OM-n\-Fkoh>U'TXk]AEe"6b+C!40X]AtL-)]AH7*?V9.uC\1d+?:4-D#+f)
Vm\bAEqXp912H[5,FM![/Gj>l,W+M[\eWA`<b>s`Q$k%XYa,"g^;ZdMG<-:!r%F#D6=p%FMb
#bu4bZ*=.rL)gYr!<LPlR+_9u+Q.<q"mism=N+lE^P-),j66"T"CI26nujH=S!YQ5)>mk/l7
)*"C6s4+^pa&#)#)A[;cR3u\taR@0BqXL)r978Q!&\0EccHrW'(,O8O&4R0;[VVHs:Ru68`*
3%J3;o#ZNu(J$=QFZaPuk^E_!hDEDM,#0B2WJ2ra?F7h]A-rnAk.KiLj>Vs8)t5ioILUVYK+H
H]A$rFlLSH%GLF5Ln)cY,Q0`cGGNR3P'UB0)?.m!BY)(>aE5QfnB2rk]A"jFfZ@,`+`?+s=\O?
9_0Id%DJhQbs8:CC`;hKg`@*9liZ^Me>2Fb9KEO\f.IchG&_#\<OMs06cI,(.#e4-eD)=b_3
/Tl"-A!0f)a'H^FC5*F]A-)EF=Ci73-%\Acc*[kR%.n;\HNa0mS4DI/V\b^TM1ik$hc/R*HD=
((Pc'WYh0^,XMVJed]A6su!H'rc,(;C=t*R^DRT9lBl:;,nf1a59h8oKf:GfkEm%?rK@9FJ3D
A%oa-qH>lg!4GMk2B`1F1^;-ZkocBL\e;;SV_4CIjYH2H?2f_g7"cR2hnTC5A=?cHImD=uU9
@.;@F-^!I<`62u+J#k9)#6/gl\VJnrOtgj]A<1j5Z*9FPFD8d^.m$0H__1_@>-p&Bg4<$kgja
D!ghanC]A93N;]AP.5foE(>V-W1V-53Rc)Hf#'H<RV-<q[goXCUYeTFQM%FLdfV53R%pu>^k;u
>.a^X^i*2#<u4tj!Xm'49-Y)oHAp@Bj_ps+&/2b\N8Vf@kf]AmeF<Q:)+<H=>\i6Tp!srTb3I
]A7cXAm&VdFmj:GBQd$55+E=QeG;%l@SleUL@K[2VKelZ[VA(iCd0^Im`jmR%T8nB/WRcHqJk
\54a&!="^^`H9AX\&#>Iu'RcZV/lEXZ>s?(#4#@;Z289tV119%G5g_bp+^u:FdX[mJIB9qRj
_3lm2)W:,r=*XG?Hpn7V$>GZ#8%o?<_^_tNY-:dOu.iC![M7MT&n9pTI*siJpoKcTim4\lBj
PE?>1&n9/^1fZ..KAh!<+.K$nd(^!EK^cCmor(kXaC4.!R4eE4&#B]A\jP8V$(d0WjZt]AU#'.
]ADq0/p2j9GnF?7:JAjh'J8P9GHG4W7hdp(2or'sAZ'%&Wi<tU1(l='b@\6LpfkMS"j*kYn9-
e\p6Fhh\ACX@(^nq;P'2BA9T8H4S3.`T\$hI05`^9R[4EQ^"rIHg[U:k-el>5Pt(iFZAU$jK
Q^&FrJ)[m/l\8.ENeiD7p0ZDF<2QS>5lZ:XW1Ek&Tdpba82UPGJ)L>^7Bse+3M>HRR0Fs(lP
FEh_D&<#`i)1d8GbG-JOl)a4II5b7e_mU;e8[/rl:I-casZIa]AkID"B&Ruq=5p2HcuR%pPZ4
oQ'mclp:mF?,&lt?mes__H<J_(dgkhQ<TmkS;RA;$l"1ZKLS*%F=G,>4+G!DuiAgLaX$9*<=
_&@"X??0k<Ea?o\mgmp6KJ>>KAS299J58l2P!=\D)9<BnC?2(;=h3G%?Ol/-q4,ANpP6MWad
mBR'\(#A%7an!;6`&=KVnPY_>>MEZ;@m1JBrLt9Ekgcf*LN[RuG@hogF.dDQ''Imqsfre"Zl
lmS'KX;VF\hlU,o<!D"Y)b:S"UWeVft`Nh3CWC9@E'VIGj6j'_6\:n2kolDukNdn?7/[Q#G<
^^]ALqSLa4r9#%Z0f1%I23<SVhm(!BFT724265n`@_sQK@]AFlX2LRheMpfNM(2FB-S5+29T%&
EN)fr3jfI(Q(9`1@U?C&1Om'LBL$K,EDbQ*CI6l7)>)eCJ%?+ZqO1:,5Z;;BK$fOJ<)4h*:B
'-NM?YD,*`YdBN.KS+HBbnI)F4]A-Upf4TgLZjiH'V8=="E$.aTVL5,K'.F?UUQH3:&Df,c\g
TXFafaEOnJgV@\Z4c4C!5GLC**a%!VoOPJfFq+m6-^Bj2#TM-%WneL;LpHQ[<25Bd(jI":.U
m7D5mhHsS_!^#V-Sa1[nb9cr&(anoL$7:Rb%B^)!,V*+EOKOG9]Apg\fY^JuQiA$,oe'I3Odp
^I]AK*@gHSl6Nl2SK8P";_@tDCm7%4:]AZ`/&GcR))sD^,9_Cr`R$Yt.k6K4M;9GWVKct^WF+^
,_85.,VV,1uL8:Z.&_Me6N5l&I\Ti:KbF-0NMWl(aJ='3d&[>B?(.D.<%/M8BA/pN(g)C%Ar
^SgqO!Peb#jmA\`q;\rfC9\eBlpC&S4$H%!Nf`?>ac35A[q`TCdMJB3T4He*nqFof('C]A)=@
=<k^mL4XZI'=Be5:?jm0mJR8*<c,'6p!0IlrQ9V9%7>3kV++afXK'.qM@!Wu=Q&qpJ5$)A,W
HYDZ3+Q'5,$/J(FPVm[>WW210\oo5\K4%91n5;[lRA6CP4eHu"r]Ai%OWj,ZbU%W+aKP+f>$o
i,*!a,CS]A2i'K2DbBa/JNI1/WLUp^"L10jcfn(.\D!UkF@#mHQ_c)h<NB-K/!k7V<8/^6;tR
c>pTIS+!RGZA_M7PYN>M;8e.ct)1ea7N1"[ifGRpM%Hgc7;<q\j(hcgMJZO6jBk3=oOO9I\J
Dc5W:@Y.H"Q7QYH2<%?ogQR&df&"G2.dHZl#0R]A4cRs*rd@27JlU\XJ`l^91bfA3Yi(,@Ca<
FoERkCfLJa'^6V378(g_,+T!QnlI":>s:/3gPOOC\=/8\jSD!BAa!/fCq0e>+!p@HT\LeM5Q
180IFsSt_&&)-pGU[ii^GZrS6+,6c?;f8pl7><('?21LJTQf:;h^)*Ble>q.MjtFJMl<e37C
7>Y"G%]Afag]AE;*8JHK0aej%J%u[Hi\neE_m.a0'#YHTs(^2L'gE,/5T#t#CUrM<c)^7@Ae-M
eG7TP=__N9a($LG82`"EhPI9\)JB:m]AUQ3"iMJn+Paj^^-[A[J9e,#:ZH%%R!^Dd98:k_kTK
FehXq22uAXWg.*4I1mdS["5&K_p74,2tUh/bf#\;j]AN9rXl[]A6&Vm,pJ67[g$@0oRTu'lH\p
*U=c-PbDFtXr`cf9$Q:kS(E@RGaknU9,B.J79q[%7jpfq/:4@qF0eHajb)dVWDe*G1b[8d&T
,4eSjQ9i*C5k$JOa+lgSh7lF5p.WB>pK'`$Z-!<0.Ui[YFQOL[VnA;D[$1ChYNt?iLIu]A>67
V<]AjSo=KP1N?C98W9rtD7rsd=WWi?]Ae8uQ1GX`q9PU[9DZYROgakh\g?tnJI=n*>6U%mGSG=
[-9F-h.'Kn7#H1-(EBNdiiIT\uDD&\hpC]A%<ST=1<=R(lQY/Eo-33@@T_(PeiBm(5HH^W,Lj
k/p^M:X^$Ccr>)p!^DUKA3.-nSUQFlmP59!4R_EH+S<B;W&V%YVe<Zc62KU;'ktsbhc5D,pQ
]APGp_5S5#p\TZroc7u9I'WK&Y("9c9?Ms9jN.\4:R?[-uE5R#eN&INJF8^r?%E1XrL(oMZ-=
T+DsQm&qVbqE;XbL:>ML-m"Or-L%(n%n1<;0fcPjhZ@hEVKA!O8+/U82*P=Yf8j`s@,6U%"M
*omOD7ZF!@spnBQ<e#a`*3kNOC+t\m&:>m8ng=j%8R*#*AOk[,>%-"`snG6\-3O#"ELS@nH$
i%ZQrFDn&qQE7LmQkk<&b+g-]A2Eb;,Oc&UioH(psjO?5:kO(?j#WD>*.L<78n!B\"G/>^`-h
qXSs!R;_?7gm_JdnW`$el9\p(8"-R!N>mkDZ8F:**nMIX,8ss!TLU7`-EgA#fFaqXF$bsKG5
CC?E4&pY./F:V2IrCW`&ND,rimiUa5_)A\c:=2:DIH)@i7d8V\<7]A9:B@,Xb\D-@WlK[C(.`
l)Wb1FSn?.+.0W?VWl<M1K8-?E@>=4+mu`cl54a3;(e&G>EI:?FhaaW"X?m7sdi`\*L<tgZe
fG=e/@>6>9J=?jR.$W:M@>-O7E`G@]ATXd*TWX&!;;p\o&`XbFUcQS+f$^-[l-u6[c3N=A5,`
4BeUg<=1i!c$@?=("'P4epg%AOfV@urt6GT$]A&5R>=V#tH+6:pFjRlN3?Vj-J_b>r8s`(>bt
MmH#X1mUt;Q]AhaH7,G7E7dAY[GW,c6!chQ(5V.&2!4MOi?R)@>9CKQa8S]ANL7rY&W_o)BS1E
.33<`P-H`@qEYY36k"\aH0<Q@@Zj8V/C0+fHHgJ0HPUU?W7aRrHG'C0&'gN*Rhi*X:7_GSjG
*S6gH/"hJY#\jEUdhX@IHNi.Lme15l+0OY+`'9;,aY*q/o4\R4q8qUkJ5:hamN$0#f6TOgOD
2YC]AkGMaA1!a_hjdWn4Z^'bX:rT>Q??aq+s3r&$QGP)>0/nid>o_K(.@!Wj]Ai#>=1SuOq>TA
,3.@".cW$I:#a7_@MJp&*O'Z9$f1c1W*5$1&j%h--MXD?sg3opM#8`rM'_`OWO[HT5\&d)(i
R]A9Q3=\-Kt#VcA+Te^GsZJVep_ZHsE"i&(LlZ+@]AKH08M`Qj;4gN3.)N(7I+F^PY7l;q>#Tu
*`XBG\>8(a@@ms%SuNVu`ub[=@p=h@\A.BsI:CM]A-YmRf--\6F1nSW'osi8t9oOL10,1!p9P
`cfA$7dD<9?Jq<//4rG0$X.@_s+hkBpiLV.DY5QYdDC8S9G3+$/E;pusD7k@0VbH5MO'[HZ?
-=hHiS#&/32KsiJTa,2JB,OGVft=#N/s4=Bf:*BW+]Aj#G#,QRbqWP@fj,t5/M(,H+Hc[%+Cj
+.P:lrgrlbPkmPhuMr5_/^n)A'#@A)FReS#8_o)(Ub=IM98jac27le.HA2i^A>R-lPWC<Yj7
^Bod9[Lo#Wl]A35aCr2i\@]ApD))`U=RcFW]A5"DA!`L:S&1dHW]Ab['=%2;'R;qY\D$<EHt,E/[
EMnk#>iqX_khmB-@368gW7iN^_HT7roMT>iB*qe=s.2`Z5GaeZ%[8hOsKKEE2!6I61BR;56J
p#Xa?F[N!f`DP`5:d4@&QE02]Ar:*pj*0fg*BVp4<6>"JGDAu[X`,t1=pJ2c.T3+\V]A\8EJDn
^.3@<-PaO8WUa<,]Asd&i^2Q1?Q`@'#?8D9DM&3bpfagU\XVNn!L8<.-ahDn>Lu>:<HmD!TC"
8kReuJqFQc"3M%XdcS2S93X?9%R$Y3PP^Tk.LjFdFL5+ARMq$PiZ]A<0c8^$fqp_3[A'V)R,3
QB?Q.#hu(/J=q>ORi2m-Tl=1N;N`NRQekWk%=%+rC=%ic^l#t.FY?8b>BKJ[`N+>\)Dn"0[@
FPGZ!4T&m)&AqC.r]A^n*h'd_C<ajcOklC,M^%S@R^AAdVXen$*RZd"17X]ARNT*s`Sd&:XOh4
K%:&#$Qh(a,>Lb@NXW2[j$,i"$S)\Vp.-'jNS_60@W!-68R.Cd;-\RU["qMsC0`$7/lY*Sf<
#J:n^:Xm0e6eB=>QIF`-6eA6,a#Xlhp%"Ueec,<GuCbrGb#?M#u8^[<.:XCf=m>CQ.0o$`8"
Z=_5/RgfO^]A<2BZg'Y,,8XAV0%;YMqlSleXe\d:SHj]A0T`iAdNliK6e9T3R4S==Qu83+nd8h
W$#AS)I6*kB/Ug:2Y*^C8Y2;!$uHh<;/m)e#c1Pu;dY;'WFlo&&]A_rj""QSZ[dj2o]Ap`03ME
@ktHV,o+.hDNe4B5W8dSYJQ=`oeBL(1W:PFM0r3Ni>M=j5P$,-6jV5HQ?^p\t$l]A-/]A$<&rt
@S56!0"Ll:nJWHYZ0NcCG,)q#SQhk2TC45''U6s>:<T=p%bS[`;@*JEZ)q,XrhpM#TftXAec
4X[KbHPoBk!BM"a/th=@^bJ)^)2N9-3]A"GcXf"[6;n'Ifg9"KYH5.;!K*m$Z3VfFURhj_B,Q
%#<*Dq$e<IFnHOog`=V:upJ\AeUEQ,L]AAE<fpn]AI%aFbj6E7Bh69rM^0Cpg+'kCrn4hA3N\&
+9ng(WD@?"Z()\6&W9R8*)'`+MRc&_?l1aEni4TNT/D]AjQ2DS`U0L0h1tm[oBAg9LQ#gHlWP
i"D\KHsqfNGB8C(H<;d5>:[4>Ugca[e$@hOe><*8;`fe=I7H/g3L[2#a.Z:F2d-hR.2$_<"R
&`s&Hk77-gi,E)@uVbr'$HA-[h\Mg1Ed7mO)?(R>$H2kC=WF1P6ggo\^f75/Vf*4mFAg!)"`
6X@mTX\+PQeQckfiYkHZVH*r'=(g!lYnYJeSV4im^ChG,#`t9`GF<J=agNE'DI9)`QOQQ9P9
6>lQ8]AGUTNDH9T2rSPk-hk#`;(,+ll^ESYGAGX%:"Zcj,)7]Ag6*ZZS@M^*(X@r&.tMm^>T1j
=$oGRdmu=Tm/@d#QF*Vk[A?s4dE$)H.W6FZC3f"RAGjTWMgn<6;ipDm#nu==gL9a$e\2XRo#
oD.j1nNK'm0U%?dVDB)hN%bKIEIq;]AP[V3c<St*U'qORd7?&gJ=aUhn"\FX!t;mIrq>`*S&/
;h[`F"D(ZgY_9<NX1"oc+72]AWepo/0X5p?6CFE4TL)o(`X(M">8FuOB0R)fL4:hOF(e[,2'Q
gU8FPc%U@^2OZ6RnX8=MTW0p.?O6@k.BD"7Co@=/,!Geg=GO[E1)?)-1S#,6:5&X)NtgUK,O
hTWCZ7se)@UO4Ge3+)E:*6bLef8^+oDJ0R.%'WbH`[/G$O'+cQd*KoOB`E>kZcPOb_:`M\l@
9`=e<dsB/9Q$:pNBhG[9M$-8a`XdI!C&!67C-9CLK@)N0T#8sio)fYLfi3VJ%4lT[M092\7h
OD_^ZJ0>LS[5-Q<u(!08k)@,ZX6CV!<VK>)i"\R)N\=d"2R8^/Yb6)V78H8Eq7`C5V0@O!qu
j!-uj+MomBW%#]A'A)EpjWpI?E$@Caki$6J^lF4:#2!dU'1Hp$Gp-K4Hq*]A\+7BqcI(4PYP%0
W4).@ZIhVcV:k3r\YJ=i'D<NeP4Ne)c=O#?j?InO`=_B(lF'/Kj[AQ+X2Vd*ATaN)\cK>7:-
&kSXS-"SuXO2Lm6/X0@[QIWJB12dYO[5b@(04ru'4leV#`18Cao]AS+n_QqeL9fQH"/$+\40d
M+rJBV*It_c_OL0m-Y4oYECcDh3.<ln#kC#=baA=f3<'t/2ltb7REXK^ElChZYkR?7((Lna;
RNKE[N:nh%@k7drNncW3q2Okb\1?^9&e%TT6d84s#8E'piJPZ8'qSFTusT&.$iQC'i3I)fO-
PKJHY:o[4`^^+\KMhu(<_%<?j4imq)]AjG('Z_Bd%cg3Rpoju(3*0:;?b^FjA6==oa#&@I)Zq
'@)b75Rm;!qfe1oj/QEK5C<X=[K`pQqH&]APS+"BR1)l*oNu?732Ue!L]AFoS#Eln7R,Z<I[#b
I1Ymd#kOehj'5bVS%%L]Agh?aGo]AW#uFs@:RS0A*)4K5aWlB1Zc!_8sT%u!V<i\s,r4kV(TrK
c]A,gk-mWqB!qQi.k8dsF,en&Nd^sSA7,LmRcA2AGrOTd"dA%R6W\Plm8]AG+mEaQ7+2EXRr$@
-i2-S)QK#kdN0e;F\uqeD08AZs")))JEQ2ls(YNI/FC58:;qKI8T_a^$ItKWFbP6=B<Kr\dH
PPgOQq=G)i8AdL8%5'MpTe#\GU]AVH3Q3VU)PWUUe52gk8'kW3hK)[saDbs,TrYB?4uc356uo
bL,$q@Hfd[HkoL6RHX>Khl*0&[Nim?_1VaVo3@UHRd[RH+t@'U+&$UbEamQ\I7WKT=<E*(bK
kJ<ctt+P]A*[JG!B(4+>pNto`eN(:*L'W4o]Ad!YaW2Y')9Tb+cG0KZ"`P'XWKp&2gB6ZQTNnD
*FI=P?g/-Y*9=YD57+hAHlV8GjagTd&:#FjcmOr4MOG5L0i1-k:Qf8>2YQL-e4MG4<0j2e+K
)N,k#1-jB_@)29m?at/N1`n4*?@sF=$&<V-i`bR,hSfG2<W=f(6B?9UBBYPg+\]Allfe]AQDYr
`IW2Qs!.&`%A:e2q[X:FhUqF-E;,+A\fYn6O?L`Brj>B>GP;rR:GMbM_cC2Bc]All]AS/ZBA/I
4hD;)QDj:B`D[>/S.]ASbtP7,AlJtaV4=DgcJ8*Aa?03^8C5IBrUe`]A:7j.bARR-/Qo`MhYDI
q^+"5Ln_@fA<FDR,^i0ab$'"lIGfn;-1$A1O\,Rb"j.P78HO\KWZ[Yl-i*eD>M;p>r?E,=8#
i:eLoc=MWkS:QW>Gd:S%VFkj>/?+FsWlQ5(*K%L/$NF-V2(aS^np@)o]Ar_il#a9.VF%AaPnA
ZCDK3f#;?YG%pMp[SrC_-\QG9%BMT1'2&On5i>ps0()rUG?MeiYbpM9NL27&k4]Akd'R\N?<;
G_%rsk9ii9fHk8tVC"Gs9(#:FBgE2\[jQi%oFt=#l6]A3O+$_7q%/W*J,dBhpqVi#<cVr+l4M
C\22e/m[O*otkmb:Ioo@c-=%_?k,jP'/`#h_j^j_#jhd:]A^(YKPmsY@*sTR`Z9IZK/B1^r!Q
7G<WS<mFPfoPQ:RdjcbO;fpU^-Gcc=RNZ@>W.q4_a=q!L&jd!sM=CB_8s[(=.4rV/K9k,X!I
@<kD5]A-gF:JpuTmA2%]A$JQQ38>CBs,(agM0X5mUZj*pWtNdt&=2bCCl!j<T:U>A8$CAFd1S/
r+6lV8he+8:>4MgIhr&g]A5^KIDi-LVg]AYFL;5tm3uZRhTYeWN8AX.Rbn8E6O2fV`]AC#+d$cm
$Bh9FX>s.!KX`i:;hqe2fHSk;q*5NsdI;1\UISZ$KR7,B4^b<54>7a,)jBU""DjGZkaUHo.7
A%X7m(JM\%)/NtE(uM88kPfp!0XNY1^p#b,gaIc$Glskr&B[/6hu;7]A;r_VZ)coiHd=l5WTs
td$=5L86L0WH80?54"cmK;LmXQ$Mtk1bA)rd"+oukk)QK]Ae(<J[_UV+3=j/Q*&a"E#EcIcnL
iH<:]A2$@Ht`-ZWoJ+^n!#sK;sML1/C^]A>rW&1S"]A8#QH6GO$4a(%R4&eEFJ7X[dlgciB3*o6
Jk&RNl2D6^J37V=?qas7gmYKW(5,6O8@HI-;MqF3lK)\+,;'SLmtR+04h__p?NPmcmN%0`Jb
Mf85<1Jtiu#%h$7R5Q"8tr8d!##*/1U:/V3iOVa#kJnKRf)NaP$_HZs*+t4)h.<>+&+b!1N$
/TQH]A7TJ3JGmh__]A2?E"!KUer@q?r9"!Ab-Ag)g\a'3?k]A:hl3GUs)>ebKd2=l,s7K1b;L--
-^j;<7:1tD1;)'B';UL&*)#n_o(k2[&%]A1=(TcqI>NghCh?-.[Qc<X5CH`q.Ral+($CYhf#G
5mI68A2>MI)L%XK<\F)8FX(m9Fq]AI0$PP=Ul[G;:R=;XQ"8@?K;6NSE5;<*sqZPU8A2R\*Q1
"PCo`.EkIT?d>qYqW~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0"/>
</FileAttrErrorMarker-Refresh>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1143000,723900,723900,304800,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1440000,4032000,1440000,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" cs="3" s="0">
<O t="DSColumn">
<Attributes dsName="日维度销售额" columnName="总金额"/>
<Condition class="com.fr.data.condition.ListCondition"/>
<Complex/>
<RG class="com.fr.report.cell.cellattr.core.group.FunctionGrouper"/>
<Result>
<![CDATA[$$$]]></Result>
<Parameters/>
<cellSortAttr>
<sortExpressions/>
</cellSortAttr>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="0" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="1" s="1">
<O>
<![CDATA[昨日累计销售额]]></O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="1">
<PrivilegeControl/>
<Expand/>
</C>
<C c="0" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="1" r="4">
<PrivilegeControl/>
<Expand/>
</C>
<C c="2" r="4">
<PrivilegeControl/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="4">
<![CDATA[#,##0.00]]></Format>
<FRFont name="微软雅黑" style="1" size="120">
<foreground>
<FineColor color="-3409409" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?i/u&nnnm[4HB&be3&%)DfVpNMT1p,e6fRA*$aZ)D4RKj&_,6L:ABb2D&EM9dZ<5b:&RA\.
g?KfV4\):(hFMU]Aq=M;Bd5+E7)8[RlU4)kMC^V\bFn>J+(;6pH6e!]A[$d`%L;d1r+s8`-71&
i%j'AIeAPl(aM_V/n?Sn1:BE2^XtqePfQqMoSn"`G@STBE.Wu?k_i8J]A^k6D-5dsIJ=J*q.p
r2Leg1UC#^[,:@inM)g?mgD!?!M)do5O+6bcQ5H^YSCcakd\jDV=p$aSu+qf2!uah='6L`pD
TQiG5<fds>Ei:g)DS<r@V0Srjc2DqIsZVLjtRe^P;H\qaaMd]A4a3$B$bU$_oX-k.Dod/X+5k
.ue0Q@*pnBs5Kt_%mm;NO*ZKt0Mp7QS;S['\!9C&=u:Ar8/;^*_3OqFcU4iNl`8#TGinOU0\
bdX/E/B+'hM7K.\cP-<Va#T*:0)l'58;f,V#/s>.VD]AS*:[@Kbr-u^R#BFB8,"/-@FA@FK0e
*V'Lu\:3<S!L8FQgflp??(5pD;<2#DEh\kk@E(TqLWbrS.KjC!]A1%/Ao+orkRGP2Oa%/a'oT
!TFEa)ZI7V`lA>2R=IY^k->IH@:nhHC@4geNEBj<u2tO)KITh\C3>cP5N&XcTQ-O?)#"F).[
N:^Q-1-J-eKg,==Z(V'2C4^@MJ%apj]AFE2RoiGQ<*DPCPRqf+D&ZCVmaeq/K]A0(r-GQld$4s
ZMVqV$0Le#/.1QL.^(?]AQ!ZnoFL(`gh>6HnT';HM9X(<]AW<2"T<!o28=7#Q^;RGgkq9L%W[-
=Cc<CQ==VlG32jT[N\nmQBArfj6G[s)P.B$Z>"P*#nA]A]A!*(B+oZ&O:IoBkS;rScGIeKP01r
gpq;lPae=fn+#u_WB+7=LVniltfZMDa3eak=Z)UFM6SK<1I&_M?2b(:11?6u<f^"$HZ.^0i+
m%le>827D)haH_kIs/hlc<<bRMd74q+#h6Vk/@D:4d5Mjfar)HQYLC*lV7'0B-m=.O]AKi.X7
gVD+Ok"M%C>_/GF7Z[(H,U+J]AS+N0'D]A/9+VUarq0OUaq=m(+O[TSLWt4b$aPI\^Q.i[MuV'
hZs7=pUY.$fKC9:SI5m:Y0^Urh6nigD)W)FP8C>*R2S4'6kcl";0b:6>$GK6fUKZ5r0C-*.*
H\Wokhb#\0\"0]At\4qQWF*c;cW'b9pmDk%R/`,LmSl@S[BK[8Ue.RE%deFj7^"jZ'8Sc\esd
rSG_O^:(l!`#lOj-2TpN=TciT+3b<`Q"l#3tX6;AK<6XccmMfEVVE/8GB(?u\hVE!-J2?edH
d2QK]A^.KN[R3b@`VS[2mX&`=ccoErZ&3UUQbDp]AoQc;tg[V.i'dW%:3+&47Jt!13q1.kMF74
/)S;1AGS5At,1V0[dcjMrT>^K5kWZkdLd+QXbOm:B_VML)j'q*SQg4Ggli?EY&TI@u:j)C)R
l[]A*Tb,B#6Opl10p_]A3J#j#-,Y6QtGJ^m"o5oP7<W@Nbem#^O+.NWhT)R,3^b[B965K=P/1S
W[-2JBu,bS:&>AlBgT,iB+&ke;Y-fM257?MAP%f;iju[d.cd'qm&1WD2a6\:h*jLdT2=l),[
J+3[Xlgd81@G;K;Up\:^C/$dFDBY?-?a;BW$*G_*"^1ogAH;nBWk_ed\]A%da!b34dk"/:k4g
R5P0"8CsGR<fHg]A&0j4pSBF"U-1i+4n:^o=7:2YQQX;!oPE_P95b9=Ca*7i+]A=8\44lS\VJ!
FX"6rkOHpP5qBrsW#[l*<]A>4thl\_OZR/J0Q7OMN#B;Q@IHI4Y9h;HZqeGK*E-@%!BDSWZKe
^V,,#>O"Q8ghLeU-?.oC@J#c?Vr]AWDI$+5hF98j2!?#,LNJufR_)b@e,F>6n/n(PTpIP$Cl\
s^$_Vm?8am5NZ$s4j%A9da3I*&9fh[3/`g7U<g(U.oc4#19?\-TLB^f5c:H5\B:/?Kk6\Ys9
73/)5C`T*>]AV@/g/-.H7^&`8p7=I>-(\,V`![ZliU[kV_R]AY@O?H=mF.n'<O,E+8OBOSD0Uh
sKoX@;`H9rP\K4/mt]Aa*iDfNMGkiiBiNS9oEKP\2FQ^%U0-AF<onDOd@s6d/LZL"Z72V[*4C
OjI*UZC8=-YGX4@krc+B6(,]At,>.hd&>`F]ANB["^@WSsO`m;b5Rqn#Rb\(UY[LEGH,oemGlU
>r#9q$c*'l.f5-e//e9k%XJr/3Te._g!rX,`Z?uj@3?b%?#)GL__G'2MLPBj&:nnml]AQ#2-X
3iHi6'FWi%.P@cDcQ;rKoN_mZ;AB+ot)7a\+[kFo(42-Xq7W='4&WH\,A@X)@b#@hogAko.e
Mp75bR,1d"P6W+E-fesE'X\Ygc<Xk&-[gjfJ"ucJ'PTjC;bQZpP:Q"t/ck6TVq((54_ut^^&
p?qr9h<U_Ub-W@d#[Smgl*t,:51(i/MD2]A@mVAL^A$c]AH63Fqlaen[74#D>,-=-bEeX3tn$5
`+).4q4j;6q=]AN:?IA(jE#IS+B>eJ+V]A9lg1R^9O8An5HaJ_7[J8/L9<l_<'CrMHNVt_J51=
QqO=J3u843a!;#B3f8eI6mope;Kh8-7;kX'6^BDo3E2\e,GR9?IQ-G5;M`2]Aar_\9NHa[LME
B>e<5iuh)+r:T"%1P)IrV@EFKBWN4cQ[0eN;<0nj=`'&)W`KOi;>L6>pp9I2j/FOoogO8h3s
!MsK)rcnW0#"b(14LcA?kn&ZHK$3^)q5''t\Yp""@T,]A^P=BW#;k%GE^h;_bR.teaRSQtS<H
aOYKFi@'Vb$s8]ABe&"6'gd'XU-k"r_j>h6iGNH7E]AEPj+AmH<6Ngnr7t::j.)_frG4K%l#:d
lMC+aHT#c-&`_9,Aj>>t+hR@ciba%^<DWY7]Al>;NSrgGjs\Hm*Hl(.)c?dGf%/lJ9lp'^$KP
'DLkaXHVhN23g,^+K3hN5VOd`8AA<:X`YTo$gY)A>pf)rZm.\i5>AH&=7$6i7L!7u%^a1c,F
4RR:pKXELXbkJa="WnE+ND@O-'_[46!03Y;HfqT`ReJAKAMJ1i<bkNYu2:.c3T^p"2!fdhHW
0)Bal1k9/bDehl7XbHR/b@H10LN]A=lP#?85,R!4`?V!p:S(L<es;]AKE?S=Klb*`aj4GBj]A67
?dE@2GH30Ua+CPf4n0LUfpH"32r-""I/6N*#-(b"\NHeeNHR5T(jme$F\9]AWE:h9*Zoi[UU=
*u10!N4,Ae#(.CJ9Hg$ssD)SOF;>LjSaq,rl_*]A/&*`2+h(E%`,[\Wi,"r^,%Zf.L>\-f8h!
4N<:]AGG;Y_V/ED&2)j0l)m^SGDAq<X2(!3`l%mnmhA)2qPkp=sO3q1%U7VIK*rDEMZHEj:>f
f5f+h)tnGr`cO&V51#;J]A6p_.r,0/en]AW&QV*k6f#O]A&nBIB"HPI=mY@8(X?48TquOP6'(d8
W\Z@Jc1%Ae0]AS7Y)i:C*F81P7_X:)r7=o=f(\)/q#[,SfU'5_G0.SqW/Y!rj$6PGh$H3(YA^
(9X!G1o2%!bGL[`+"/'_FaMA;1migaSQfm,R89,f7TB-bVI@&-$dJM4mnjD%N/7#$J]A.5Z;G
4&Aee-26u2`pXc756]Ah"b1@`c`]AAHDT=ViB1(B"%PfkZN<YrnVl9:*i^:`gAo#*XO`8&OJ*,
2BWXGG`mg)Ds+kDg^:b&lV&bZNJLUb`dn7[/%1`eN(FHEf#PFP&.9lQYk,Ci*k7A$T"s/)2O
Oq8.68_,#8!,]Al3J6HJ:0hP;S&a*g"=-<FP993H]AhsJhA>HsZW1$?PM#d/=rA+^?Y"8@iR>7
p;qZkt^\r2N:KsF<oP9:nTCQhrVc7f1]A&!53p2[,!_W%K7%J+d!oD>fa^O&XWoF7QWbE02DX
pDSM[Vf/qIJlc5Ell_Sq+o9RGB3G.LZ<HI^aZEZ)<Su$6S_?qp&hXaYOe(+-(%Nu3='Y12k)
+?%a97W(5%P0a-\)2AGZjrY@S0%WRV3Z37n1$4J^HNFeR@SmOi(0`jtB9=MZP8n4\Z@0mGHg
qoO*-=khR?5YXQcI3taO,='XAV-t=uRbb:'2,;3a9"8_;LiK/P_%Kt(*'>HgnI0Y5"3bIaFZ
IJPPW.i_UW/t"6TQ!dK*/8>itta0M74"i&iBMWAKn1oEhu[$_TJuQp?BU=<iAH^3=$.aB'aR
:8WCukn\8=A<Do;lX+;SN_)fY_ls:,F?1WiimF'Nh75I"sM%_(^Gbu0R2/mn_Yr&_rRKm)X*
JAL]AT`Y>%,DbYO,2)mM?$m8u.Y#^:5s2m!hEo.>N8tB"R@T$11^qmopOC,^3A<i7P5tDW?^A
&ui6pk_:bA7H\*8'@[MiAX]APFTE4?De(Wp<ECY\:`JSXdaTkaDqTWi0TC5?0pf#8*ThOP+Fp
E6-^mOAfLkI.en,/e:4;4f\p4TuAJ?46ku`aR<#@m+=hIfE'A5Q9/@aqZF<*;^!X$aU]A(II)
XUV4"A@"S4YGpnnrl0G*upFT:Zeogg?Ksc`A`X3ZpTC,`IXgTrN]Au;5rg:."`q#&0$K9UXi=
F9=8ou/Tp>$<A[@*erD`fo+Hm=((1>S-tYu#CC0tE%BlI`qP:]AA!hB=j%Ubog)Ru*WC8i.Cd
ThW55otOgb$:_Pn)c2\esS>l3uZaC5,#7%L_!^(&Qh;ZTLJKaGX;V87:1__P\d&-\a,k@mqU
,R-DDh58gjlc!\pi_e7qUK6Gg<&Qj=jaS%I^-G#9l#PCTsp:VA634YbZJUs)l5^n-&)0R(cC
W?G$:f)!mqe-saKAsRdDE\fq-0_;6;[XM@6TLRZ5,C<(447an'4Yf(a/CS%I2E[<K.#)Rus1
bCjR+<FB.:%k..LJD58rn^m+C%L+\\Ii="V>+Fa&SCpqE0?GfU*DZ]A:L'n:0Gr+%KB#ALrA7
X1SuOLi%2o2"DPLQLj)O:.7$<20t[grBn&RT$4IEONutjjOP$m5o&-?(!hjDr<s=Hki*;aVI
]A:W^J0"+qNG$s7]A"aXY%ihtTSD?s`1_?*Q=@7%k??,.B]Au5sA!.nGK[?N#<>=='^l/$C0e$o
Is3S.u0F<0iCE/Z[*rRIeM:mu6`gqY^6cfJ=^q"g\bSl_Z,hV-pQARB0F/$Z>^)Wr;K(smFU
V:,G[0dla5JUc96T'llR'.U+M7@_:`p,6sne"VpIh,SInUSl,OK`7=?a3F8-OT#3VR=m0]AB-
UlNiV8og^@kr/FPp9[Y$M&`Q8nt_(Rg(hL:TAKK=3t543ClG:H\OS1ph`g6ad2i85O'+NcUA
hj+u9-mU21ur:--D(BsErR)t7Do5cS^q#'i!ZJ'MOX"ZR0n_]AGaNq:`UjRVI/&Sb4Q!&)+qn
,g6&0>Itb!k\Ld^^KW5]ADsV#$h+51!<:[?HNUltn,1f2(nrdWms]A%a'#&$#+'^V*Xf^NVEg#
+gXkM#ABrCRob2P#8Fi/VlRT_rmcinLlrBH.-DL0OkRll$&3[Ys'+0_rg)ue=$!r~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="11" y="10" width="114" height="72"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="report30_c"/>
<Widget widgetName="report30_c_c"/>
<Widget widgetName="report20_c"/>
</MobileWidgetList>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetScalingAttr compState="0"/>
</InnerWidget>
<BoundsAttr x="233" y="58" width="439" height="87"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart0" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0"/>
<WidgetID widgetID="438c1c2c-90e2-4666-ad27-d5e684fee540"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="true">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Microsoft YaHei" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[默认]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.custom.VanChartCustomPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="5"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-9519626" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-331877" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-20614" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartCustomPlotAttr customStyle="custom"/>
<CustomPlotList>
<VanChartPlot class="com.fr.plugin.chart.column.VanChartColumnPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="5"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.chart.base.AttrAlpha">
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="6" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return this.value + &quot;万&quot;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="true" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="0"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="false"/>
<PredefinedStyle themed="true"/>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="custom" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="5" filledWithImage="false" isBar="false"/>
</VanChartPlot>
<VanChartPlot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="1"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="true"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="1.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="true" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="0"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="false"/>
<PredefinedStyle themed="true"/>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="custom" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-10243346" hor="0" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-11950436" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=50" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=50"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-8988015" hor="1" ver="0"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-281518" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=30000" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴2" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="true" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="4"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=1" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴3" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="" height=""/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=2"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="Y轴2">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="1" stacked="false" percentStacked="false" stackID="Y轴2"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O>
<![CDATA[1]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
<List index="1">
<ConditionAttr name="Y轴3">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrSeriesStackAndAxis">
<AttrSeriesStackAndAxis>
<Attr xAxisIndex="0" yAxisIndex="0" stacked="true" percentStacked="false" stackID="Y轴3"/>
</AttrSeriesStackAndAxis>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[0]]></CNUMBER>
<CNAME>
<![CDATA[SERIES_INDEX]]></CNAME>
<Compare op="0">
<O>
<![CDATA[2]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
</stackAndAxisCondition>
</VanChartPlot>
</CustomPlotList>
</Plot>
<ChartDefinition>
<CustomDefinition>
<DefinitionMapList>
<DefinitionMap key="column">
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[同比分析]]></Name>
</TableData>
<CategoryName value="月份"/>
<ChartSummaryColumn name="2023年" function="com.fr.data.util.function.SumFunction" customName="2023年"/>
<ChartSummaryColumn name="2024年" function="com.fr.data.util.function.SumFunction" customName="2024年"/>
</MoreNameCDDefinition>
</DefinitionMap>
<DefinitionMap key="line">
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[同比分析]]></Name>
</TableData>
<CategoryName value="月份"/>
<ChartSummaryColumn name="利润率" function="com.fr.data.util.function.SumFunction" customName="利润率"/>
</MoreNameCDDefinition>
</DefinitionMap>
</DefinitionMapList>
</CustomDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="7ff7350d-479d-431c-b30e-3983184db5f9"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="false"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="417" height="156"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="244" y="380" width="417" height="156"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0000_c"/>
<WidgetID widgetID="562f0b50-821f-4349-8d1e-77fd48d279b5"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart00" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="427f32cd-a31c-41fa-903e-0057dcb0ecf2"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0000_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="决策报表body样式的背景颜色设置为#00142E
图表样式&gt;提示&gt;文本的格式需要根据实际数据内容进行调整">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="3b9858a7-bdcb-4799-9865-891ed60a4114"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="112">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="2"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="false"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="3.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0个]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="1"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="true" maxHeight="100.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="宋体" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-16724866" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-25532" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1418919" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-331445" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-16686527" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-9205567" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7397856" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-406154" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2712831" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-4737097" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-11460720" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-6696775" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-3685632" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<lineColor>
<FineColor color="-13219745" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="季节性产品分类" valueName="毛利率" function="com.fr.data.util.function.SumFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月维度渠道冰淇淋毛利率]]></Name>
</TableData>
<CategoryName value="区域"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="c85ebe9a-749b-4bf7-a504-cface7d3a5fe"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="257" height="118"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="178" width="257" height="118"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart0000"/>
<WidgetID widgetID="562f0b50-821f-4349-8d1e-77fd48d279b5"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart00" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="427f32cd-a31c-41fa-903e-0057dcb0ecf2"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart0000"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="决策报表body样式的背景颜色设置为#00142E
图表样式&gt;提示&gt;文本的格式需要根据实际数据内容进行调整">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="3b9858a7-bdcb-4799-9865-891ed60a4114"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="1" size="112">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="2"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[基础面积图-项目情况]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.line.VanChartLinePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0个]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="1"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrLine">
<VanAttrLine>
<Attr lineType="solid" lineWidth="1.0" lineStyle="2" nullValueBreak="false"/>
</VanAttrLine>
</Attr>
<Attr class="com.fr.plugin.chart.base.VanChartAttrMarker">
<VanAttrMarker>
<Attr isCommon="true" anchorSize="22.0" markerType="AutoMarker" radius="3.5" width="30.0" height="30.0"/>
<Background name="NullBackground"/>
</VanAttrMarker>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.00%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="true" maxHeight="100.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="宋体" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-25532" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1418919" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-331445" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-16686527" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-9205567" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7397856" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-406154" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-2712831" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-4737097" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-11460720" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-6696775" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-3685632" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="gradual">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<lineColor>
<FineColor color="-13219745" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="false">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-2958103" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="季节性产品分类" valueName="毛利率" function="com.fr.data.util.function.MaxFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月维度渠道冰粽毛利率]]></Name>
</TableData>
<CategoryName value="区域"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="939b0a2d-ba17-4826-8cfd-7d371f3cf353"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="257" height="118"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="695" y="67" width="257" height="118"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[822960,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[365760,3444240,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=FORMAT(DATEDELTA(TODAY(),-1),"M月d日") + "线下销量榜"]]></Attributes>
</O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[mF1r:;froWn>R-,!bi8i\+FZlp:qkOOD?."#71DL=#h07+kOg\j"^h"\#BlS,E1<C"Bo?W7L
0FT@*4]AY#qVQ^fO4;-g/Q^aaY(GR@\]Ajt(OVhGds8^k4eM3)ID=tCV_M;#gJ,+)'ZqK+0/=T
&H52E+XZ<ob[H0>)CT&:&PWOPVr89h[j4nbEP9N0TQDVTSl8mudZ#tJmo=Z_h6?MfVp$fEfd
%`07H]A%:&@Hs>1H&gSTI;m:a7ke45MWt7%fODS%h-O(H>=XtldY&SrX2sYKm,PmUDVk%gGVN
;q(dBb#=I`b7dL1hYR8`S593q"Y>2B;FE%2;m=hCg8`98hs:_ZhM3_%6"KKV/aP4/=&Q7s[3
DLQ4&IFW?t=k%Ikh?$8[S!F;E2SjC()@@bLUAl7[5:f_LnC<NRWk]A@m9(5)UBK@8ad,-qj?0
0ME?:$W![Sgl:_XL*E"WHd*rM?ue5OUf^i_<,_&Im`nE(7e+?u]ANYY9qU^W4ZiEfO^UG?.%G
s0L(fPS^qR_q@,3#CX5'(=.+O)H80hL9*Xc`?@s8k7YYcGZeiL-V!j]Aio]A26rZ9r[h?oPnQ7
[sTW6=d6pF[@Qc1!>XPk*;jfDs3\KnBtc;J^dU8NYMPCm]A$A!el"?iIKl2L\qk`dN6VOOVR@
QDC+;n+K0&b<X3U3YI%p8_$DIE9;GoGeB"68p8H.sc)59MS=eRQaNHo14*niuJJ^DSg)pg*h
dsFT1G3.3n$J$XRMbWJ$cM21O4Kji.RW/k7fHgO1_c*DqB<n'*)KbIR=8u:u@$rpg:#m,\GS
0->(WI^?f-$I7B=U!emJ)ZoW%3:b&o`\M0fD#uI\*t:P<L!$iH#F:LFI)B'==r1B#X59h<]AZ
K9PHAbV@^\BnOPDMBm=1\P0`I;PMGF0\_puaXQG3b>s3]A%0Pe0m\io%!d5TeDF%f*J,8]Ab&J
g=MR/&P]A6!!]Adb+gE$t_t)^GS,G2b=q).&o+"<-fkS2YoVst;I2Slu_(dr!K&\'LZ>isBnt-
)["2RirQ/-e75Ukl:SHn*SrW#45rW%5rV"'Jl;sReqSAlVNU"1OdjYWAt;?e2,(7Os@k!ju&
+?UcUMhrK5So7r:L(a:-r7)557c)ppSK+MlbDnblC7+Raegi$8=P=\:JHS7T5UK9C?qWe'K!
Tu_Bf1p(K4Wc>I^aTGfJ'q]An5TAR_W7(U%WWDL8HNTHO]A8:Z>rk>Y<+XX.cNsBN=kNE29^o/
mio_bd79pk#V^Q'pnT+[t%rB\"+b6VEcJ'oPbH'A^b1tl$kp8OLbfI_9WSIFOFWB_#DFiMF(
#1E*4]A#`'P+=`CfZ]A^@$&p>PU)<@e,/gppcj`%]AOlDcPj4)A]AZ3YbgOg;$0'sEZlHRE]A`V)G
l@OX#%O'??fk_k^2LafGYs_U/Ai^S?pF\5`YC#q9;SK)r9D"W`lpfFF8*/f!35<H-a5JY7bO
FW?ju[(:6\!h\>=%ZAE]A%O&VP%9"=`Nb%Va)DZ-/RT.=nDQ1b)37OS^j@\V:qXNoc68#<<pj
sfj:aP:'-$7V.&<9!4)3>)\G5%qQE/nLs%[&9=N!cM&A%?"=n:`ph^HMWfiaUW<?u;uh9Htj
EV<HT:*UsQpBLs!+T]A$u=>9[$[a#WJ[mmgOXO,@;teA[]Aa<RtBX-gFk\cLQ3!*OXVlghs5!C
>X;i+r$^V74:J7MGSsM'VPe$-peN':kU#,Ta6(gW.>LX[*M@9^tA^!D<#[3=hI`\iN.)@7^&
n4Ba#_Q,l)I+SQL.J-:h/,,F/r0UR4UKLPJ\)%0~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="245" y="153" width="267" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[822960,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[365760,3444240,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[年度线下销售分析]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?q0XRTC9F8Sfc7*QndmR\`KU[RQ`U;K#LoNTmAr)DO)e*@s\.TOY$&`#(cP88Lt/'l6ennI
k6-'IR[t(39LU^fgmZDe#a9Jq9_jQH2Jq77:MpgGSRVcgrpLds'*jlaP3sqs=?3q5QYM8T8i
nG63=\cA<q/c@A0`qLLmABo]As5SPU>q4[C3om)6F.s+G;f50N06roF$/[8]AH;]A15'*<]A>FE!
53^=nDA-8<jE?)T0qHTqV$^)j6i*iP`lCkp4IsjHhPXig%nd`n<\j:#9:cr<O6%]A:N[UJ*]An
Zl]ACOGp64>LmNHUq@c;=@rbI!-^ag\^NUb0&D>UiF"R<?I05'6t5cn,pA,`B'a"+'sN[uf`s
\GfCFbg*YnoWC<8O)q`]A#<qZRb!Q,pA),=.Xc)D6%WGe'6.9U"3qAA*^L<@uMj^mSM41'*g/
bmuNmb-PY2Z&c_>n)4@RG.DXt8+m0X0M%-b#8CUYLmja_5r-3Jp2Vg*DPi"7.EgId<F(gsOA
e6Kr:LhU4h\.`CK/Z:KE4XrO1DjHn1k]Ase6O7K(sfL/T+O1L)'FJ,C`H`,%\<%@`[j:\<Hep
q@),Q%HcRUJ[n")+Z6.^LsG)G^#>SB%H0!q6-B2fL]AN/UTZkrM.s@3.U<cldHO`^GL2#t;)"
`#^B/;:6pU3G0TV)d_e2e=o;(`TRWVn2[X:Oh[^M$5$i2G)7EskYgr9QAQpQVa#b5<l`E69I
)Zd_0XUZVafZhXA/Za3F5TFndmZ.,m5*2IT2A@9^QRnKVacA"1XQq2Z4lj$#Q$h&uobG_g0@
.B`jp?Wg>ko.bj`KMc7F_kOq^1^dECcpPpsDbhk`k5hla,Yj;RQN%iV%Js\Xfn:Esn$FGZs9
qAHPs*jtTO[QXJ[1($('$#=GkIkccn\g+!/Qd/#oC4cOlSY1"l=1RbknVYJ*#VjX*m[`^ONd
j7617@gnO%PUpmn]AFC/bd)`7VkuMV_Dgg\B#ULjZLJ+9M)O&2]Asr2XnW_FCc28eT-4(h&K6S
W2!99Hjo#BLpG5QJF_qpXtP#792Q4=L]AH:m5B*ZBXTj#NZqd8.`b4+1ZLL7[-ea;Fa]AZ@6!p
gL\MBjLK3ei,+TgRD'8)NF]A3NPSkh]A,o'LB'd$)Sbj0>t@=*,%]A&`b^qsCXo&?_`Kn9_>`ah
"GF5Z68o'k3.-N>eCfI[a'gg5r2IE$Jp'VF8OM,g3Kl`h5Z/Ef@C5V7mK-!o[RrXsh)-Pik>
H^@pAp&[O(A/4<J93!4(DealW1YLo*OH%28SS%@UohiGdoIC(;u'TBbr+$DVr5!)0%W^ZU[E
1D\6+5\ghK?'c^=[>HVSg'=EGL)&.N(S/<0TN8AA<`W#k58^&E`a5S>j,@Gr"=:tOX)RD:ga
pcE2d;a9005%O#fE@69*_TZ8ESSX!j(3\ZhH4(B"HT4c#)IMYM@FB]A]AQ969(gIFcR#;D0qQ;
1Y:KBo_mk;nqhknm0ZR>#-D1obHS#\N"=s7M@K4d\f(-$hTQ=&Q@u,nH43r\16,@"YERn7V8
4-lVsEhWkqc:LH964():M2%QE(U:Yp;qIKmn-^TWMo"[;aa&#tA8UP%^Sn>OG2[g&&!ehD=n
tS<?+sXd-8k84c-9i;!Ug;pWKo)N)==WMaF"#FCa;YT#JZ)]A0ZGO\<Enn8Q4;fPR.d&?Ga[_
]A@$7C9GNJR#:>6b23!&@hRbKR#t?P)qLVWo:Y/1k6U6!ik[-36h2rKhqM&r0hK"WP;P0X4;s
2;M<G20p_`m!!0rjt)_YaQrfE3fM+V]A17r`(Z"pF8W+9os*Yr.G&,NBSW@jiO_]AO58,j]ARf^
"8".:=!<sT3,sN7Z`C-sF/f586r=`aAZA)/r/RaCV@R7c0l;,*Ug@8j3fG_sX(HQk?K^/k=R
Ga7hmY<XR-GWc0?'A,;@/JS,@BN&7QlQ1Jr=GbWCB64Mei1h&-FsnS&[.-1!!P_l77kHBI0V
5R$.$*Gd4he2h@5,%@$0bjWCs"im\HI%*uS;eSkrH"KsR@@hQQPik"&(E(md1CJocq?!J:``
,7!dC*moZ![^@F4B]A/>$ic`J2NT4JR,_)N5mm3-lDLif:Rn^Y2-NH_F9tbW#L%$HH%NWk/$2
%N[^-$<aLb'U>]A667TR1\P8asaf$\R<m/agaGRld6,,hZ/u3jY='(D$QM:]ALYq!!Q1!"]A,1&
:]ALYq!!Q1!"]A,1&:]AL[Grs?8/<mCKnG@+RdM')O/g$nT^]ACoI@<;IKE01;Q5#/CK]As3HWV1c
XY0FeR1]A#<+A$-*HQpk:?Q9~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="245" y="356" width="267" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart01"/>
<WidgetID widgetID="015be30b-a786-4416-906f-f22d74aad54f"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart0" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="a467586c-2f7e-4f67-934e-3448cac49e03"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart01"/>
<WidgetID widgetID="b2758efb-a20d-43fe-84a0-89b5b43add7d"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="【使用该组件前，请先安装模板组件复用插件 https://market.fanruan.com/plugin/0a49e40f-99da-48c7-950e-54a24e853204】
1.决策报表body样式的背景颜色为#080722。
2.设置标签&gt;自定义，将系列值的和显示在条形图外侧。可参考自定义标签-https://help.fanruan.com/finereport/doc-view-1882.html?source=4#3示例三
3.点击右上角可排序">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="15" bottom="15" right="15"/>
<Border>
<border style="0" borderRadius="5" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[▍华东地区销量统计]]></O>
<FRFont name="黑体" style="1" size="128">
<foreground>
<FineColor color="-11316397" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="2"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="true">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[单位：元]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="64">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="4"/>
</Title>
<Attr4VanChart useHtml="false" floating="true" x="85.0" y="10.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[线下销售额排行榜]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.column.VanChartColumnPlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="5"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.chart.base.AttrAlpha">
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="true" position="9" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72">
<foreground>
<FineColor color="33023" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return this.value;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="1" visible="true" themed="false"/>
<FRFont name="微软雅黑" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="false" maxHeight="30.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="true">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="true"/>
<FRFont name="Microsoft YaHei" style="0" size="72"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-12810581" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="custom">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartRectanglePlotAttr vanChartPlotType="normal" isDefaultIntervalBackground="true"/>
<XAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="true"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="72">
<foreground>
<FineColor color="-5000269" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
</VanChartAxis>
</XAxisList>
<YAxisList>
<VanChartAxis class="com.fr.plugin.chart.attr.axis.VanChartValueAxis">
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="0" MainGridStyle="1"/>
<newLineColor themed="true">
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="2"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="0" secTickLine="0" axisName="Y轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="NONE"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList>
<VanChartAxisLabelStyle class="com.fr.plugin.chart.attr.axis.VanChartAxisLabelStyle">
<VanChartAxisLabelStyleAttr showLabel="true" labelDisplay="interval" autoLabelGap="true"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="Verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=0"/>
</VanChartAxisLabelStyle>
</styleList>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="true" valueStyle="false" baseLog="=1000"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
</VanChartAxis>
</YAxisList>
<stackAndAxisCondition>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name=""/>
</DefaultAttr>
</ConditionCollection>
</stackAndAxisCondition>
<VanChartColumnPlotAttr seriesOverlapPercent="20.0" categoryIntervalPercent="20.0" fixedWidth="true" columnWidth="5" filledWithImage="false" isBar="false"/>
</Plot>
<ChartDefinition>
<MoreNameCDDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[日维度销售贡献榜_发货时间]]></Name>
</TableData>
<CategoryName value="区域1"/>
<ChartSummaryColumn name="销售额" function="com.fr.data.util.function.SumFunction" customName="销售额"/>
</MoreNameCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="16210619-d60b-4641-99dd-712fddc2b1f6"/>
<tools hidden="true" sort="true" export="true" fullScreen="true"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="417" height="184"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="243" y="172" width="417" height="184"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report100"/>
<WidgetID widgetID="61730c8a-7c6c-4cd9-8d29-8699cc6b57d0"/>
<WidgetAttr aspectRatioLocked="true" aspectRatioBackup="6.551724137931035" description="">
<MobileBookMark useBookMark="false" bookMarkName="report1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="36e9078c-ee36-4c4d-a00b-bf26f2320f87"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report100"/>
<WidgetID widgetID="40ac03ef-343a-4fbf-b91e-f18c23abd29c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="1.body背景颜色设置为#021C23；">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<FileAttrErrorMarker-Refresh class="com.fr.base.io.FileAttrErrorMarker" plugin-version="1.5.4" oriClass="com.fr.plugin.reportRefresh.ReportExtraRefreshAttr" pluginID="com.fr.plugin.reportRefresh.v11">
<Refresh customClass="false" interval="0.0" state="0" refreshArea=""/>
</FileAttrErrorMarker-Refresh>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1714500,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[3810000,2438400,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=today()]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=CONCATENATE("星期",switch(weekday(),"0","日","1","一","2","二","3","三","4","四","5","五","6","六"))]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="2" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=format(now(),"HH:mm")]]></Attributes>
</O>
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="2" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?qZfdoR=#BsghTgd"\=d[!0r=gTSS&5k#N70QPN4X`i4+U$.'@SEMh6:G<N>#5b[X+CI/+A
5$tCI!OuX9iLhYQP4C,%Q7@6_J)G3G1P"Q^MpWS:(25J+(,5^AHd#n"09&52kaDY[[224Ztr
\,<r`0eC4<;8l'A^ce$A&9@B0fRd93@&rsIB31ZEqc9ZTC%mSYaG<8o_o4Tf1E'7o*;KqWuj
1oSG8o)a8Q*)ccSWr/Z_sQDdW+K\>A$qrfE>I,XYf4L6oipY!/<Ea"0)F0[*[UbdSh>pNAtM
S`3sU*iq.;D>2$F<ClhorIK%mG_J8#Vi]Acbf0%bZG^p.@'9_$n/3f'Rb%oN&#Yc7AQ;+<g40
Y)kXVB[.>K]Ak"ifk.:6"M#W"OlrEYc9tDTF]Au0YYKWWEU!n,A'k2gp,8cPlREkBUVJo\iSS7
`T;%Uk.Rm7NuK@_PI[b/2!-;2*`-9jS(D7SaN7]AS/3YejgW3N3LdfX_hF+9NB=Qf86OXE$;q
slOuKXh&GeY//O'_Pdq4m?q)9R6n^C%VOtRPSTm"cSBfIDTO]A/e$]Atl50W32MFrlja!XF:aA
^D"&8DEHdK6KHN%MO@BfIMGeNE91fE`>^*-nD?cE/%5G/NB,"=C3S.pBEK%%C*`+os=U.ebj
BlITf>^9.6<DX<a8WjDf.aQ1afjmWZpNUsO[Ne27U\[.L"T+Ghk$>gWl^=m4?ffH=B-`P,*D
mB*`G30?q)Lq`LF+0D/R2O=r@T^5derS4]A\WmWCT6an3,G?#,'[:\`,3Nq<K)Z'r+`GQ;N<D
fXLX^BKof)6T]Ac24YP^$tD<o\-Ut3qlQ+h9U/7pFG$a>HiYRL-LJl1G?.pZJ#>Je8,!u)]ABX
ab(l)2RDJ`VCdY874rUf$?nYX`LcuK1Lt+>13SstHq@<tK08%dU)eM7m4<<]A[#6egWNqHo9]A
O,W-&D3/TOm/Jb$MO/Dm,4JVo4O_9Rt=Jm4T5*<SUl8AhiRMI+hnU%)_is&&k_OT#e*2\k?2
!Y3#M>%;Io<HY\U2363c(8,dap+ba.j)r&YZF7U0^T36%/mYA)Bp6=O$;g*tb8:>a$.8)!%t
[]AWHoB"CH8^K?]AO$<poi*+Y?QS3dR$/?Wo)4ARm]A"Q?lk4C';Ze_9#l2.ngO2)fUZSpP_&UZ
8RuLZ>OnIg?6R0*di-gri5+]AEMN7T,1ZiCd&F)9B"e5o'o4;\RUU0]AV\Fr>b!'Qjfioc,K\p
4D2qg5qBWr4CJ<<H\T[EPYQ06L7u3nCa=4SsDF;MhG>^3t[L'WDmMQ5L7lf.g?t(*R78*1IJ
;Fh%nFrB1TD<8PpUoNTLAD&m__2QHH`V4kI#u\06[f3L,0e`<c586-'[U`-m2bpHT;pCo]A4J
5Lo$.@A?*1smMYNMJZI%_+7+^S$rdH+Lm,(Kl=U)c%-O*)b')>etB1,qEQqbD'^&u'0<Z`n!
6P\O4i8.Juq<ZS`1`HfA9R/>$$)'@Jl#K!a8u.T8GYtZ_B8:W.j_]AB%\Lp1$]ASK!+c\]A2nU#
>?=?V[^(n7kC)O\0PIYDHHm7!L'[X<85CWSgb08lU@sd6-`i)mSjIJ4H"n=:J\T@!MLS9LJO
uE6K(<Uti0"g:t^![`h#S[F:)uRY^2c\6sm#/:1'M2bgT6=lpdHh)R8!NE)K=Wu9u%6PAD:i
[!,)#3:lum;ppofuPIgVuR"a&X7QlAT<.$Q7mT0J;CoRG?"JGZIYn''`eQGStOpSX7cuGm-@
79:%GcaF*C]AG$"2dR&EU?q%K>1YE#Y"tet/0;hE0d&X"Uj7/$NlT<V2gelLa!golJX#f3S,P
[SO]ARUBte+j$t(qp;q&_.2dj:n[D\t.TZ!"UiON=O8Ac[.r`&*9C;US<H7!hN\c(KZ%OnYXd
On1QFuNUGMJ4(.^->gc^86=+%$Z6W"\ej;Sd5la6?Oc-V+B'?))]A<M)-D0.;Ei:F@!C\g[.C
EI(WkcZGO@jc'<G6Eq,eib/9R"`5eA<4?9o"=T%eEr&dO:nMZgB@"]Ap.grA&GmD(ne+.J"F;
<#)5o1hcEYDZrb>\(O;V&^8UKZCoFIs!LgO3_GLD6*r@/#dC)10'!p'a@.$Vj4[e9\qIpP,7
:Yj%er@0cPJed&0!$A%;[p`/a/&OYGis2j^/@MHB5kZjXHpq-<>"T^UZe3(sI56)UEnK=QGR
rc2%)(F:m95aLtu\Z!#@]A@,=)6lbcH;;^U.4g*nUKEddTo(h4:C6e3.Q[1E@:+XY$Z'X&fW2
=B0Sd"DsM,Y`e_6lBhr=b?=eZH@?$'#RD!GtGh)7ST#0dp+eZ7dP6a&/I!d?GWo2($"c140o
U<.`haMX[ucOp8k^pJL3LUg6o#]Ar!eRW3"qj#nhB+kXc<$GJ+`lVit[0bK?6r+@@5:[r?pg7
CbjkRMkc<$hp`NiniQ1I=`Ibs6^d0/a*Z!;,b,A"`_BV;ZgZ*]AYC'u8B0NVj+/5N?%NeY4pi
V3dM+/m3YC,9X&=*TbJosM\(<hlIa2AHNH&STXKSXa#HOcS<?7EFaM6$FY%1N"Y?'i@rm&B/
j,q[X7uVSV/Cc4I8a-9\>\otUSe(9`b_rCe3Ofhsk2@G<C&bF0XJ!aiaG"SQei$okpPZX2Rf
b7S@!=i"\ssK-:d/Kr5^CI6U5c"V<FaPVnstBcK?%<`LoQ%Y.mngmqi+-S5IO?C]AAg&!FX0O
5\'&&k^mfpXH,ksRCuR+5gbcE8H&13(+&=M'mTbGRAs+jT2^mPaa:[49jk>@]Ad@PJ]A"di15E
Kce_hMPCh[PCc]A?/.t[dqXI/TTJ(aW<L"L-q\mCl.F.?Jaq&rguM4`Hr!I..q6B+riIS<`)S
Zn5.:@picTh>CL#5T-`<Ch%V8'JcNe$FLT_06>i)>Y/23KR`FF@Q+Tme.fD;1I.=OqKq1:^,
J?=jRQH$"AdS`8u0?^28APg*<UW__lS5P]AC%<l;/;JOA\+N2]Ah3E,DX3Dl:5Umqb$ZR2Qe%g
T_#91ccp3#E"p]Ab2MAif?qUUXH/#LaJ\sMAN^81j6IGo:blB\5rK*<h;[G[$A'IRG\+H?m(^
hE?@4^\*cgG-1!j%(CBF,>Y"U7TgeH+GO70<`bB%i-jCGKSJL?kePnTN3JEUgMnR\ER1L:J)
rM&m!ZbGsUlIX^]Ao4VA^tFHE`NI]Aa`!4.e7mlkJ%VD0h>cZdJ$$%1b3cfL":P.q7`rV6-bfF
>`(,e9W9T]A01r,EE#jGQO'rdTJXE<3/-+SmQd9ViAuQkEZ,1OW+eH5U$@)TD3'H/?@bfg,cq
>ZGj!CCGGc^>uMUSh!KfW+A'`(\4rrA+NiV_fh)JZ)/uIAH?JpC]A9<9,#a=Y_kbSR?t4_A/]A
a#PIr6n0e#%TNfj7[[O:qVt^r<I&de(TF+_or<J]A/ME[2Kod\]A6*fW%PHYf"a#\^p6Abns%Z
ikOsI)Q2YN\?&$&'UnNV14Gki`2$1XE"nk]A9iA+092Jl@'UampGI;orI/@=M7mI490rZTRpr
M5!k_("aR2q*SWE^!ebS"1lf->+E0^n3>OWF7C2aQgpd-]A.kl7YXT/%>f=TLQ0<`oYI.-H*j
RC4;u[++$'GW13dtaK-n1j/nF?/;rDGMaI"b#-lfl3jhYMqTq,`Ul-2hSTD/RSRJ]A/.j30=`
*fRZb@c#DH,i+.Z3G<GSG([/++fYq=^#%'QU&l3Ga8*\'L;$Ke2e(d[?MdH&FH^Lk3n0i5Ff
7YJl;36se=d@pW'_Tj:kq*]ATaq)]AG[2!5\lsH!Y.%AaSQKTNh,+"KXB>@WT_CQ);u:k%iLt[
=e_@?J_6+I:KKA)lXmjM<2X*0DpVe`Zq2n%9DR^e7-N+#~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="190" height="29"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="770" y="2" width="190" height="29"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart000"/>
<WidgetID widgetID="b9a5ea43-44d1-4234-826f-667a2a6dd755"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart3" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<ExtendSharableAttrMark class="com.fr.base.iofile.attr.ExtendSharableAttrMark">
<ExtendSharableAttrMark shareId="74b93f04-30de-486b-8515-f94fac227b0d"/>
</ExtendSharableAttrMark>
<SharableAttrMark class="com.fr.base.iofile.attr.SharableAttrMark">
<SharableAttrMark isShared="true"/>
</SharableAttrMark>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart000"/>
<WidgetID widgetID="798c9f2b-3278-4647-b5d0-6229d6ccc099"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="1.body背景色可设置为#021C23；
2.试管型仪表盘百分比标签使用自定义展示值标签，调整标签位置。">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0"/>
<WidgetTitle>
<O>
<![CDATA[销售额排名]]></O>
<FRFont name="微软雅黑" style="1" size="104">
<foreground>
<FineColor color="-919809" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Position pos="0"/>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__4040392903BC97AFA0731BBE11115636">
<IM>
<![CDATA[!E(&Bhhb0)7h#eD$31&+%7s)Y;?-[tGQ7^D+p\AQ!!$%!_Lhgg+;ma=5u`*!m@=Ja'\D&hn"
7YDj`3qe&Aa+W=LNa;$7^Y@+eg)/!\+gO`KEcS?3CD>J\@`Y$Ao!kN%m&1`?+A#7MCc@?3CD
cJ%d]Ap]A<eiMbJB?dYIi-P5%f)-*L::"4l:YMS8\Ds&,f4Pq_,U=-'/'N9J.)barWWJb+<j6V
1l7/MYpkEoLZEd]APs!8Q6.cA4\626&G#b<J5BDd-^GLfMPPra7'_C]AOgH5L&BbET7.R&X^f"
#DDQ,#i8)&e*jb4jk^EI&X@5)(<.guKto$RNC]AH@3fcJMN+[(oRGYX#9<R;^%e/Xe&Q(!a3d
Pfs`]AMu?&,69gU6Gd^^X4A.4USLKd=qkD+e7+0NJ(g6*)!bmdX(m((Z6a-(sb)3i#ZB?YGH2
1ujEg[_O.4t(sPa-NMUh,`Xdc*i-C"Yn5]APN0r<\`Gd\WfE]A3aO3fF[Q$H-WZJCMIdMTkkDY
j.]AUKl.OrFFjlKu?dRn/7]AR2P*;Ee88.3HN:.4]AVL;O!0JP*M",\gf1bA#*\R]A?-ZTZ]AmWoC
+1_RC*e9h)!IuE3_1fK3j:-/S"b3o2bEZB93HCe.nR.$Q))9jCJqQgf;&cNY0#5m\gCMNZV7
@d$Wnk#qcK[oo`i@?.[t=]A>+-o[Z)"CdAR\ZcDUR8,<_6)h\g_ATG?;Fpl4A*inF-AEl#6Ef
rq7CNh,hAjVbls*!Q6IN4]AVjMO-<$'-ZUJQR0Xt#5*61`"VRNqM$2X165!(iaA3@ti0!Xdde
l(uX=tCifaC(=#Q^+%:f7jYj;Nl/0.htkabms_cbe)<Tr<SL_8lt9!@7,f8CTp,BlP7.DP0g
(*.VA]AO-(205d1+j,;&aq+=Wb?Ssq*lQ-9t89BIpa,fP36OMAGEQ4W+1.n1OE.I$n*BAcNM_
/o[R5!hj*1lSNS)i8hi#'BtKBusm?66IfK&k^>0d=+7+H_EM&KY5N7J3!a_K^&hrOpX.T+,j
<*i@;V`5_Y+m9$*^j!6S.D:l.76Z)lAFJAa+*<B:JLr.U<>OWmri#`Q-2\01&#0JPnE`%Of1
3^ee"09SF<"GgX>"$unf,^_me7=QJD^'G$PKS2"A<qd9NX6g$f,^b7fWN)"U<n/-#8ZHSmqI
3Y%![N,D['GH`?>FDSGhm[Np1o;qqtm>,l#5)=p$;X!3;g?RpUq)s\nD':\Q-r2L*%W/hAii
))%3aR)8LUu]A0A49Ah1XrDbJcYr^+Ta==!Sd6J:B5TbPUSQEL9*_5!r49$+ah8LQ7-JeudS(
Wd&Ii!\QgZ:C$;/bo6GoXn)k&C#j_;($nq_5!WV$`*T,W$;QMabp0FGpN$9kW'PRn7"C0GU.
L,S/+6.>ui^fN'QBn-O+8+j6.OLJnH9TO?5l*36K8RIdqO03IJe:*_6"2Ec7)9A1C&L5"."k
;*IDEZ8,&A.*<>]AOhQL3]A9jAH(kEoZ#t4P'j)C5Y$f2L!0;7K&$QdJSZ.qo%Y=+M$V'BBEW2
'T(L'8*.(XnL0,Bu]AKi^>&98]A:Za!d,de/J/QEKA7nP6r+3I8jNb)j=X?WJd8j0X*Rsl.D]A4
3]A#lP*`JVfUh,C=X3c'&CO6GKAD;`u\WP+J0s0b5FTaSAtN"&doS=?of%DU/7>L(@G"'Ee#]A
VjjrWjS4X\XR%AKc`Yd4PlpQDf^qr%#S2Dfpd/bPHiSGetsH;dW\g;9]A+5!P=FN#^)]A"NUC,
ncD45:rB&T5F%5dh8\.u6@>Ki'!L^dQfXJ_H2YT^(CoMib`/Zn/Imeej&LLZl$a)\d_:Ri.B
]A#]Ao(kor8[F$,e_1Zpqk!ZY,dl1jMg8OkY#*':"V.#T>88<9?1cR\7EFS%uAfRnr`IC!L3'C
Sp?RWpD[2>:9D0mW"EF&+D;lc_MXX>T`=GVGpi9NnaAHr@6WpQX35bU+X>!mGYb^mHo0g./I
uX#F5WAnAF\3-;5ri0!&:!Y6N9*,?4,R)8mEdFS;PO0h3[pAYFYgh+AuLKjZUGe!Eu6U.tbn
0;lXBE`eT_iL1g%q8_g5BsEor9k0)7\KI%T_86O&-i[nR<RT$f(6WQY1:2`qch>$s)%(IqnH
u*G9=eoIJ[4EmFt.=HhXtCBfUMnqO[0/K:^iRdVnmJQEtf&[[<Vlb@9%oS5ut>U$qBOSJ^7T
4'TqaM8#TDGI3aBI>8!#V=+od?/1ImYmiL!)u:%^bAKLR)u?^Sh.hLS5(1TibZA#SRSCuL_Q
?U7Ad_:EAi$((RqXc<o?#Y7bWB<5dqK[;9rFk"1e0BnP+I]A%R\&)PnjZ:dY72G?H*,+DR@Lh
hYo_p/X@kGF>_?.jXsq6C@hj^p9([U>\HXa/?\SKW^^B^`?+u2*fd\fPV(7*M-7i<i`V>Z4A
r+HE.E`Zk8%9iuDsXK+#+1F7/Stp+aHi:+8sbpV-;h9D;G:@/;bY1V,b'`qS8=':EK4+.7`W
Ui3lfA]A3JJn"&"XkQ4CEK2OhGtK;89)=7f=Zh);.dla,_r=XSXhf4%$Y4[$.K@+:S-nL8rW?
QkX;fa!1^sj,R;eg`!tVRgC5B[M+8o6eo8X(q1&diu4_&$q8LIJIN/a9AOe%CgbNG'L:Uod%
D=PpQ>GIXG6V%K"ru//d(.mIs)blqi0_*oM`kI5c`tdKZMo&*'Dt)iF7@'G2n9AIZjihmioC
6>TgY=62,0BF1#;L2ekBHD`m=eaDO+-pT&itdd,GS-.f3Er@.iBMr]A1qQ_\C2P3Yn@Ms6aVX
TD?pEOEGXd^?C+1n>8_PldL2=%a+DSJ)jC'qr(7;o7)%:5aZRKq/j[(3E0Y!p$,sq&SMe:j`
!Eck5",/!&*LO"g*j&Q^#sMS&ej@pIjm9`35`ri%1Bo)6jsWt0&j5'UY.oAK:sNbHCkL[Ch]A
?>^^NS(Af72m7X3ma"-'BL>R$_M"Jo#dat&IA&fu?-&uQm=J-)7mB)m.H8j&6,`$Zioo1hh.
(LZoS>SU_)C9-"aeAeMZ]Ag=0+Cod]A]A?T`da)Eh?-4,$noC>BlF\WG;m0Go^@Bq-fbrDFI@YN
PHGHsrDM7-,\f%jKp+Ha0rcUq\i6JMT5Q(N8MP'mXPBuTPh=Qn\rfNWGi8416&+Atto]A4?sQ
h)<uE4+WOi>[K3O5DG25BFH4i8X4%79AoD(Z0UB;0(uB7G6LKWq-$UeJ4-;SlOp>f2S)9eip
-Zp7eFak/HrG(U%/XI/+-*?GD*hn6C83o:"[]Ag?SUAR`^C3eJ3QJ<gN^XjCu_q#N]AX6AH`n=
Q9<:&?1d@!c%:_+YN=Y+Gko`/q^t%EPB6HsDqV\qDJ_T-qp"e(mTa+Akk:9Q#CadYIs^cbI*
T,-;;3^q$epi2lbD]ADWVILYT:!1_bV>`TViH!Q4`SP;Id@;PacZ$^`rGhii'fkXgFqR%5221
tH`R>Dk#hKKhUuIHcLrpiG%A(M[115A)bD(RT:#k'Ds!T^ZRM*$3sE^=3DEH@:$IVpRnlUKB
*@+.b(bmM5jhRTghFU.a-&CU>aGe\VaZ[-%]Aj!k'VUaRP.TD#'bhebM9@=&QQs&=X>IgkP/h
T5R#OUfG=-re`lXR9.ch-cVD+CI,UAl-R#Fa9-jB&ZM^6&.N`qj-;iIfOdirKnVeAc!;,NKG
UEVFb4%:JQEX]Aj54sDiRo8t1&8k&q:`XE5Yr99<YpeQ\?;[cqCpZ^&.0ucSpM>_83HjoF6#1
&8`*XMP[)#'XC%2]APA'kQG[4j%GgD^9'05*8>5^PW""=e,nA.#*.QSHs<YW7-9W_Oq_1*-tI
&7"\gE;s6Ym$k7NC_;L>=:&IaYiIg>YYuGr:)[W)fGEq7(j-;aEJ*^EmgWl(f1`k]AkC"RW=W
(qY7$oP?b$9'!sojT.-YAe`f7\9u1\oHcNVJZfY?%_I=NtuiN#5qi"NLUa<qO=m,mDH9=I2S
<@o0Er$@jd`U;-UN==h&I8M0lbN^^be?kifm6N\'%Q#!FtRcM*(RLI&Cn`<b;(UUp3Fn2J8M
"%S-]A5#g/H]A<Z!>^>=J)PC$Su#J#'VB$%'u6*!pGI%@S6hgJ@_UuP2LX/BHXM:8OCdkPoR9h
*BfrYHP&+2E[-[f6Umi!oOo/2Z^K3[ogp'R4PpZYIk9.I`P9nak2(8'fpg0>Zt;]A/Id;jj'M
lnnbimr3&XtNugH1r^qtMcR3qk<Q>XEORCr":%E[Pf-P]A+\[*U>i&s]AhT\%h(,J2(F)YEWYU
@<uUVnrT61@4BDL0bNbiLs"R"St.+qa.3gL4.jp%JrhVTNY%uHAu&uZnH3m5f;Fl_Vi+AKCn
UgkV[[[ToD^DU!5PC"q3X,eug17T=aJm8-=P_=OZn-O4eUsV=SM!#s-$`kV7CW<dKc9_W_5e
IGoaY;6YH[Hu?TYI^eT7Z&l[IqJT>GL_B[>Q6&5G"KtPfbYIpYDnG)g!Nt54q+6leP<>Jm)i
g:,oiFQP"u`6/2!+/IP.Od0ks90"1HnbaG:u\$pR)SQ&'DKWKaqM.^.?=ImLs<EEZZ5ooJ`M
jXA6<13thL?+A0)lflF"Y,InKM1C\Xj;fZNgQ9.X*jR32]AUQ,hZ:%!\*(F<?jmb.e>o)E4n<
EC64oR"`M2c^7aI>^G<Ij]A@G^+QrP=A/DV<c2uW(q%>d*R`9)@q=G*Eju7\CH=Xe0j!rGks$
ni/,.AE9ZBr4nUO3)mk^,^JNkB+T#dH;_&N"lM]ArUW\qV>a7q)0<D`9D&<.7r^G"D%E=p/d(
7M[9pM,85*d$2..:U89h^tLeF't(Ym`"(2,><V&-AB^=N=p.'Ym*#USN=ri=\\im-&Un*F]Aj
nV=&3T2bgj>C"?LW:+7]A5/LAm\n8,'O5BH!9VE+F-HE$uF%0$!t5M&<W8r4u$_*=7-Lc:%B]A
I20(qo\i.BWg^-n%&<5t>HU%6qneBFF:mKh(Q7_k$TgXAPUj0,^Fig1*8iD26O&G*mThL>u/
U?=i&,Mh$W&(7-&Njd]AW@O5d_IioMTAW;i.G`Ztf-5H;\O5)IY$!HShpFJtJ*?!s7lslX?XL
>GOE9lWHKl2Kn,VA4)N[)&>o]A&r-'$fe72VGT!KuWgS`-,4*Z\cNrLtN_-V]A/BY`s1[,'_Q1
C&l^?)7d("cU@8a:*E@%fXQYRg.hq*-?tUrfk9C`^s9EqUNZq%^CQkEWT;>:494i,:g1B(^g
[Nk7Iu7S#>r?@>#2Tb8#a\F4/(G<?el\(F\[')rJoGTG.l]A(e,cc2hc0#;cFr+i1V#!Oo?XR
jS9p`ndUaPFL+]A08fB\klq9C7H%T]AF]A))uXaNKQROC3!Ah]AE`>2;]Ap=XQQp]A9[bN6`Of*GcL
dCH4"AbQ&LD5f<gj()g;N[^@eE-+u&\SjUGbCg>,'UcbSTo*sLq`s`m-OUA\W]AW'hRdnNE[R
,-ah7.f-iuR3RqN(Vi0J.@E^-F*met-Wj:8-^??PlfD6n$1"0-5:jNBjW+r%kWb`dNlaeJqH
Mq<DmZo5a1Oco&=rE_$qY2EHGLB1YCI6h%'6gVtZ*LIC53o^8pg?QS@4%o'+$"pg,ZN,-Y1D
.8TMMHmYKV+N1\^QX0a`u2I>OGb<'98JWqkBm(^l@3='MX#::.=T%=sNgW=RLDGN90!4<%*&
V/CXh&Y2mmhgslU8Bl'(TfZtR7D=&";+Iskj]AT(t]Am6&67\PM=Jgejk@o\naCNsEGTBu.\$5
a$PH>R^M@7qrc$C.SX;6'P!PCIIXt8>hRII7QiWl<\>T3ta[?//Rq]AC!'^eo#1?N3"+Z.4#;
MDoKD0ZC1ND]A28^g:DIbP]AYdggcjK9qVdYJk9<L;VMp7n]A^@]A@)I;:!::;Xj-YmL8BD07H%k
@CtO?+msk1hs?eU/U<_,W$Z_J#i:b]AQ4'L5d'cDl]AsPr<d"X)DVG]APEOUQVh-_6t<U;M"a_j
*;tM?h6>kO<aAGU.U`JPbuABpUn-GiCM53"+Z042^99`$31b,"h4E#bINW+[(oPmL4"[GCh.
>"T)&#^93OT5AIF\#@q+G;d[*8]A<=kuEbAc*%rrb7L]ASjJ*Dh0VP)#R79(&2ThB("1M'P\*5
`,e<Q]AaGFi8Jklr<$HsdLPu)`6ON-3tG,UDLb]AJRb2oVn"_BD6T>IhEp"6$EW4gp0"I`POAr
#p(8+=g4mF89a$;M]AF/!m<0a2l1C3!D3=&o5EqQ,FMf6V_cS@^8&+0:h,7gp0GAPC[0d>(>#
Z3B,Ep%/Pr05T_j-"G-.]Aq9\_[V`W(mEHLPJj6%DI/hF65P&aHH:D/FqL58EpBretjqF^@H,
o/HghgHhNMbK6;*6C?,+ZT,jJcAa`@H/Lr&kHp@_#DFTF<iDa)WPuU'W7iDWK**4E1_H(7bW
mO?7ae*X4:<lBFAMXrQNZK:XZi7I[)sr>-L_:m\dtoPRA_V>sEr`<(</pd!rV.d=[3.pIdE.
F(AJ^ZQB)d]A[Wg\A<dsBD5i@6r=hk1aKj(PZGoD5\^,KZ=Rhi2k(MOaP@?ecJBqih*1FNSuK
og=Q;]A=C,0TfG0V<*r]A9j.?NX0:[eF0?59Y\3pFi'"`Yd@,+/!k-3j7=Q_)oF^<PnYs<J#ae
4&5tiq0Tt-N3Fm<mbIFCq'oCB5h-j"*k<MOV_CFD!Z6U@.X5(:6o]Al4Y=-nepNio=X\8*#X&
RL0^e2_Q7B[\A,om916>*/mE[(:fP5E<ZT'OZ:]A3aoOP_+Yqop<<)O5tqXP.-bDhSi4fo\Z0
ojj$EMGQ9&cpEFgKT<:iT#guiu+?4Q/!Y)u`5Ua`g1o,A(/:a$J2gU8X(_ElKFU[2n4%o.?k
luMN^s')]A$=7$/jJu6GmV^b?:7Ar<,m_Kp.g=6DH/e`b*p=WH+a(3VSTpDL7.)&*>BA4KU^&
&]AI2Yi`:Ttp)RHnM5kb/.:Fi[8=#sQK*=a0GH[N4j0hIBsqTA8h_/t?if4X.\[d9!Hi9FJ&.
,kgOc/m,RUD<264+!pJ,0udBBNsFbP4sW6TSL\pW'MU_kWOcfbS]AS_.Q8F)P,!AQZg'(ie<N
:2`SM\:f$]A]A>N]Aa*NU.U7S@R8nKj-[Mu:.TK+/'Fjh81o(MIi,_^F?bhl"+[#h5ao*gR]A!J/
Ur<sT-[,?`9ZCg3Cr0e;;P.0=njtqFIP>^hm6%iE2nuZLL/AWi>_p^BtRG:XBASa:_g).rf#
fA$6=0a96.,%Xa]A;FeK=/f)1!@kX$"`Hq8AJ4.'_n`6TnM-'Z8QVnN6=cT!"rtaK:XK;rdM4
'R,sR\X`Ik'OZK0:G4DFfO8mUlO-sdY%P?++4b2)=,jc7M%BY/3g*Pms-MlnDK^$l-u^7LAr
9(:Ykc/ASO=7U-&*7M>@7e6L9jQ<J/.cAC=!Bk<\/M<I)P#W'VReG<Q7gFiI^F<#L/@fgHGi
D`'kht&AG8.`S7Zhd9161-mP/gQLa\k6'_S"u_)7e@/Pq$-`8XA.gUL\bk-<8GJhAJ,fX&P4
7\RgEN<:6iFP2$`\L,;sAhd9Z0#O8XW8_;L\l4^_78eu+$i:R]A[7h73HiR@UOa</MGf.-S;o
"BB>e+;B5#&LhjKeF?YN!.s^iL3_cFClj8I+7;[AmV/DD1X-u4$#'S*Mu4Cp\0\&[KeW6GaJ
k7o\i&m#<E3oEec-.UoRH<`PX/Cbf.l@*ii8\L[($al25n.&=G%E!A[^`,^A;tRP:Y0>n<MS
JgXp%3_E?=lkE1-(,A0G_%jU4771=+g58\o*75E9,-+*!oo.\:p#'su^.lqoLJGYfI$3s3qW
(NAG1P*taotLuj9KQ%j]A@OgP6ldHlts#_R@HA83W'AK]A5$8(?1LC(L[C0g61.59hD%KIEjm9
!V$\LS4S\#56X5EUC<c(/402=+bhqFn"T0)8TGBDIY#5G6NsjKA+!/Ur:o#f4OJcp!RbWb#9
_-;r4hsZl6<LcO9t;e'1PGGiM<&!H6=b4D>F"j=ePRr$5DquA""j;A?g698Mr]ApQ5NaOg0IZ
h<9oq:YE^oV7EbBF\K07&]A"0[[EM<0cYc,cGjVr.j;R#sL1F<il#`[Mt48BiYGW?>ND$FT$l
0)ECVd1EKZ`?besaW1_N\WR[O_^,TRO?7HIaUnR=@b6Rsa]AGI9ZN.]Ai3jGE'iY514QJD9=:L
%IOa9O8?9u1Vg_s@,CT`f9ke>KGYq'COg#iF1&+Qj4Ik0C-g/n.]At:h:*K.^/'S=i@+1mZ;V
.BpnsZgf8s(jR*aS-GSO=<)ftem\E]A8:@W"a4$]A;;_'KA/a;r]A(UoRHlkG7Fd:55S?HV!\"1
CDCjSLo'6.[.+38BW=VH;HD3Luf*eKpJc#0nLc:5]Ak/^SlI-'OumCWT&?=bHF`?MTP)X\Rms
\<TB%ljSpoW",9&c7l6fl_G>2,pfeP[Q=5l>T&[0uP<4Hs-VSO]A"43qTg"47A]AOmub=Q'OLG
rgkQ,VF0k6X&Pbq_'Il1p+[,VGi1,<QeY0qho"@ul6s/"iRO^uHE:#pG0)q:H5.Y$bN)Ee^E
:>(prBu`<7M]A[-[N>hd/kopiSL@`&4LHe.XAJX)>GJ\F"/H-jL*'7NugH1oOs$%_,%2ZMteQ
YjkbW>-4!iHFj5!JYU-K>]A,j+]AoXkcS,^=hkH!PHGr+[H(s!4pBnZ+^)Aad'pYrp:d6b6;eO
uedPCWm@PT!C4*B!09i3a&o:bX8r[D7eL1PI0&fS]A.CX<G(ZU/'ZicCE[-*(DGe0R(:8t<g1
$.N@->bY%0X+a,aI&15\%+j5ZI-VW2/`)nXUA*$6n7lP>[N&X?hjasMiHHL/K[SP0X7C86qd
B^ku*;$rMlOo.0pKN!hdOAgh3E"856'.RdR0O`AU3D=2I*$K1_'W/a8+b[^hU=&1$M)rI&S/
*G[*!;IRY&&_')^.Ch%%nFPR%Ruc5>@f6eq'<s&6ghSR9Afk<[X!ZEbM:c1JjR'e]AJsG\1(?
FL*cpd)GU'?Xn\f4rk^6Zrn.jt=Gf+sPRO9(lk]Aa@ZW\*M-jItW2BKrH^e>4oU5f'!%.K6SB
=\^#^]AEqUqiSNNph8**>(dgf52f!)hHH;@_N(MNe1e\BhdeU'E9g*Cf/$CF,SoT`Dh^gtI69
jGEE?QN9VAV\(sL"8eh,OINuQV!EMXP^:kN(,$OpoWK2de,d?A8fof"d*'5&Uf^^_u!NsjWD
3sDSC8C<FI.]A\GId4@WY$(]Ar%2D(4tkVVBqH3]APEIG25QHua/d3'Y,ek^epuMJLPL0DX^@O/
9<lp0R:T$bM\=^2R2&qo,3c\"=18GPh3W%<lPWVqn=pc+$t>ERW`IYH6Vs]AsI1X9]A'inB(jM
s[Ia.JY6j"YB2-Hk%r.gK5-0V>nPN$?OiK?M@o$j*SLg^BSQf4&rbPG+qY?l>XZr0%m(?5"Z
hIX;mJcE_[6NLtY<D_d7IB?s.r3JeYC-?@_lDm$+'1\AQ!aLL:=6BapIf7-4>)-_U>Y;-QR,
Wb?<5XiI/3.)b?$?'^4,b?ea$9ocX4AcXF5qTL:2BtYcRQ;+2p+`Ik>p=r;,I=g:RYj2&G[\
5!*nrin;`6jjcTP.]AqES]AqfE;Q/]AsQ91;W40,.H'4B#(jmW<p2MA&cXPE.gY8NQL:3:?Z.M^
.uR0+-BZ^VE(sp\]A<kmlm/Ip!2T3RD1nRSFP@OM&U=qE)"%A^j42Lq]Af-J^GgDjeU%Ca?N&\
4q<D6)C#5C%8O)+sQB6;p'R/ebQUR6YFc<kUX$cN5>@0jjrrj&BSGVEkk]A8[E7%V0@+UW92'
63G$HL=slLpNKBiFf=q*Q$--D'*rp$H8D`kdekW,0o8W$d6d^5Pr!>=>%K;9^!qTT"`i0o[L
kRR*ul*Kq+kC5'7o0J$*)@a`D<O:S)D>Eq1c!K5l784eh>\j1.FET]A;s)@?-ps'6s-`co1+_
agOLU0^/%`[YQh-7uk%f4EA)/i*k+V5&S!ui@EZQ#Hp@67*G1>[e/=f]AB/BbLu#[Hc.\?`=N
o"2Z'_q7VhOS7MO?PM[$\+HLBXEKmuHceB5ZV`_DcggM]A(9X!>`E(Z8"/DD7,b9F_gU5>IIq
Rg60G%bU4pIKhj%LG@kGCT?Wi;S!s.`Chc.N;b$@m))Q%F9tf$)Rnc7Ch3`qb]AJ6OFfD:KO(
oF*HBJMSjI1n8gFf?5(25s;5f<-q(=G'_`cJ3j0>0Ne-CWtR8XZ"5$=D^61"U_u0UYooJ$F5
u#1n+K@+I9)om>ApD;jLqKj9W^[^skf]AZn[36FGZu4dLoKF6kniU;Q)JsflRY,38)51?@`t7
-T;pV#R)]A_ZA)+O1)%kUWJOP1$94cUNCH?/0MW3O(rn<uB]AA2"6P;'tJep4j3\2s+p`(.1+9
1Tp"`^.ErAsAQU#2NgRGhr26-ibG4ErLDE9F5^h>XaUN?!>@!+Q8t:jl4(3'G^:r[ZJAI\lB
F%I"AKYjZ,deA@H@([@q-;!.sXSIsBq25!$t#'>XKJF5[i%cS.&LVPi3<pN2`of)j:6b`6L=
#d/QhBtZSFR8]AcCA`:*<r1RkIJ\KoO5_7g(JUG#!!!!j78?7R6=>B~
]]></IM>
</FineImage>
</Background>
<BackgroundOpacity opacity="1.0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[渠道目标达成率]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.gauge.VanChartGaugePlot">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor/>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="6" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="false" duration="4" followMouse="false" showMutiSeries="true" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<GaugeValueTooltipContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<richTextTargetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="true"/>
</AttrTooltipTargetValueFormat>
</richTextTargetValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<targetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="true"/>
</AttrTooltipTargetValueFormat>
</targetValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</GaugeValueTooltipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="1" align="4" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="true" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return  (this.percentage*100).toFixed(2) + &quot;%&quot; }

" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
<gaugeValueLabel class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="1" align="2" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<GaugeValueTooltipContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="80">
<foreground>
<FineColor color="-1578771" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<richTextTargetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="false"/>
</AttrTooltipTargetValueFormat>
</richTextTargetValue>
<TableFieldCollection/>
<Attr isCommon="false" isCustom="true" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<targetValue class="com.fr.plugin.chart.base.format.AttrTooltipTargetValueFormat">
<AttrTooltipTargetValueFormat>
<Attr enable="false"/>
</AttrTooltipTargetValueFormat>
</targetValue>
<HtmlLabel customText="function(){ return this.category + &quot;:&quot; + &quot; &quot; + this.value+&quot;万&quot;;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</GaugeValueTooltipContent>
</gaugeValueLabel>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
</ConditionCollection>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="SimSun" style="0" size="72"/>
</DataSheet>
<NameJavaScriptGroup>
<NameJavaScript name="当前表单对象1">
<JavaScript class="com.fr.form.main.FormHyperlink">
<JavaScript class="com.fr.form.main.FormHyperlink">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=if(len($area) = 0, category, $area)]]></Attributes>
</O>
</Parameter>
</Parameters>
<TargetFrame>
<![CDATA[_blank]]></TargetFrame>
<Features/>
<realateName realateValue="chart0" animateType="none"/>
<linkType type="0"/>
</JavaScript>
</JavaScript>
</NameJavaScript>
<NameJavaScript name="动态参数2">
<JavaScript class="com.fr.js.ParameterJavaScript">
<Parameters>
<Parameter>
<Attributes name="area"/>
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[=if(len($area) = 0, category, $area)]]></Attributes>
</O>
</Parameter>
</Parameters>
</JavaScript>
</NameJavaScript>
</NameJavaScriptGroup>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="2"/>
<FillStyleName fillStyleName=""/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="false"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-1" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-10243346" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="custom">
<startColor>
<FineColor color="-12788517" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-12785949" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<VanChartGaugePlotAttr gaugeStyle="thermometer"/>
<GaugeDetailStyle>
<GaugeDetailStyleAttr horizontalLayout="false" thermometerWidth="6.0" chutePercent="0.0" antiClockWise="true" slotBackgroundColorAuto="false" paneBackgroundColorAuto="false" hingeColorAuto="false" colorUseCategory="true">
<slotBackgroundColor>
<FineColor color="-16635559" hor="-1" ver="-1"/>
</slotBackgroundColor>
</GaugeDetailStyleAttr>
<MapHotAreaColor>
<MC_Attr minValue="0.0" maxValue="100.0" useType="0" areaNumber="5">
<mainColor>
<FineColor color="-14374913" hor="-1" ver="-1"/>
</mainColor>
</MC_Attr>
<ColorList>
<AreaColor>
<AC_Attr minValue="=80" maxValue="=100">
<color>
<FineColor color="-14374913" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=60" maxValue="=80">
<color>
<FineColor color="-11486721" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=40" maxValue="=60">
<color>
<FineColor color="-8598785" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=20" maxValue="=40">
<color>
<FineColor color="-5776129" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
<AreaColor>
<AC_Attr minValue="=0" maxValue="=20">
<color>
<FineColor color="-2888193" hor="-1" ver="-1"/>
</color>
</AC_Attr>
</AreaColor>
</ColorList>
</MapHotAreaColor>
</GaugeDetailStyle>
<gaugeAxis>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[]]></O>
<TextAttr>
<Attr rotation="-90" alignText="0" themed="false">
<FRFont name="verdana" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="true" position="0"/>
</Title>
<newAxisAttr isShowAxisLabel="false"/>
<AxisLineStyle AxisStyle="1" MainGridStyle="1"/>
<newLineColor themed="false" mainGridPredefinedStyle="false">
<mainGridColor>
<FineColor color="-3881788" hor="-1" ver="-1"/>
</mainGridColor>
<lineColor>
<FineColor color="-5197648" hor="-1" ver="-1"/>
</lineColor>
</newLineColor>
<AxisPosition value="3"/>
<TickLine201106 type="2" secType="0"/>
<ArrowShow arrowShow="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="64">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<AxisLabelCount value="=1"/>
<AxisRange/>
<AxisUnit201106 isCustomMainUnit="false" isCustomSecUnit="false" mainUnit="=0" secUnit="=0"/>
<ZoomAxisAttr isZoom="false"/>
<axisReversed axisReversed="false"/>
<VanChartAxisAttr mainTickLine="2" secTickLine="0" axisName="X轴" titleUseHtml="false" labelDisplay="interval" autoLabelGap="true" limitSize="false" maxHeight="15.0" commonValueFormat="true" isRotation="false" isShowAxisTitle="false" displayMode="0" gridLineType="solid"/>
<HtmlLabel customText="function(){ return this; }" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
<alertList/>
<styleList/>
<customBackgroundList/>
<VanChartValueAxisAttr isLog="false" valueStyle="false" baseLog="=10"/>
<ds>
<RadarYAxisTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<attr/>
</RadarYAxisTableDefinition>
</ds>
<VanChartGaugeAxisAttr/>
</gaugeAxis>
<VanChartRadius radiusType="auto" radius="200"/>
</Plot>
<ChartDefinition>
<MeterTableDefinition>
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月度各区域目标达成率]]></Name>
</TableData>
<MeterTable201109 meterType="1" name="区域" value="销售额" custom="false" targetValue="目标额" customTarget=""/>
</MeterTableDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="d7f365e3-abec-40f8-9119-87d5ebf457fb"/>
<tools hidden="true" sort="true" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false"/>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="228" height="294"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="3" y="58" width="228" height="294"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report6_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report6_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report6_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__F0218C63DF4CF4BE9B8F39D694DD9EF1">
<IM>
<![CDATA[D,t@Q;qDeu.S5:1O[]AXcMA.<a1e7g?R1r&\%"_;@G^oo`$t-jW;M*Oh?UZ/RBosM^!``ib'L
WOI"G='i-q%Y/gA$OfA;Jg(,&#<!^YW&ljNH5'hf\YGBC0hbcFs9#S;s9Q"@5$)4^Pr9["]A(
iZe(qf0DT;q$\EJHID%a115]A_bV_=Na'7W'Q.;3eGB!"Rmd&E+Ne4$LHmY;=u-C_Ckd;bfG7
X9:Y$Jdme>&nDdh*GnEalQA+p8]AFcU\.(GF0h"9r2G^O]Afkr>l8`KspN",U8Gi>8oEcQFJpr
TP%nHpine*172cO/0/H4$N69mi`/(/=u(-J_HF9;W`=GW!6i[NZ,>5k]AmR+:IlWuu*EkT1-u
@*/">J:r+a:;cYD?<5hMm[eJE"DnFMnM`BE404X7BZ=Z7<FoG@+9StP:TAaVYE>51RgZYQ-t
pCFn;Qm8??no')RTcWG(jH"Ekf+ncCR"639go'b3eIo]A+cn$QG_H:&9KB-7qIb2h]A72a6_H@
B*K?Zp0Tc8c.=*VEk]A":*X'q>==popkdgV9hr.-Mc2=Kn@E:Lq6cutR+Y^`C%'kt[Jk18(l)
1[*`UL*L3W>qf4oUduDhd#b7G2#g?=j!d\BMb#rgt[obEj?frg"=anft6YFPUBdulql$-1Hm
ReNb82cl>,8q#/Ks6NtIY88c#<oKp_8`RW=Y0N_W0s"-rKA/]A"rCk0)@:nW:DQSI"k*B(L"]A
ac!?I(FN<\naua#79s$Ar)ZF_4e@(,12H3T%9?H(>eQmc@+fT&C>*,_Z4BsgUe5.:'s&eMQS
p+[oX?1o3WH(Am<&kQb^(-_&/]A-=Vap3i2hK"6OQ,hOkN]ABB_>X*5LA#2Y5kr$6f4p9_2,e:
Kd`Z4H]AauIb=S,'%9BS]AYcf)^cP3e;LE`9TG]AoC5BId)XJ#mTQkB'u"(TXTq^7RUnCXb';jO
3E\7P0.LGs(f@>jTlW`f<<fNp$NEG%6&P_i'q]A4Lg'4e,OKR3'Jp!T@uDOG34:`<r:bK4+g2
Bj5_VYT2`mVcF6r"7oJ05Hobqn8-u7,L>mFcAFf;KXq["6#Fgl)L&Oe;0JJT`<bs<\]A!\B8R
g!PS]AgW<BTi%qWHZ<hbgjW^(dQ!d6s2.88/FH@>aI"thc[?.X)/hNEY'6Q%@Rs#Vol^C!YHJ
6/2IYcf1b;+@`)T.W(N.inV_7_$/_'mkUo5X/QP-i;a4+_YJ*S/kU90Xj%L^og=T3J=[16I^
7*M%&DakE>YQ6iMfAP10's-=[lEj>;IqJM;m_MfTAe\:J4V6o8gIC,4796;K5`-qU+mo1<H[
G\1ZHfC""g6pC@@adYFI[`ibO##k0[oC3T@=dX%n;U0rY.*05`R3DE0fDI0aZM2TL,5[j_YJ
G*X&:5&U2D=/^'`IB/l;5V$3=3YVGD8@i<fFQi0G-=Omf(PQMO3pUtWaQP8Lj*Rj1?^PZK/?
$He(2)u4B?-s<:KD^4/mELS:C7Wun;LRT2h9$?EB$Tb5(VYjW->j=[^O"3JDZdIFXpcI#IGS
^^>-EUMP=Q@g%^/[YPT=tpOUQG@ijpX56D-SUDh7qOfe"!O_^/U0mpS-'8gbR'Z@f$B+5Fb1
!7)h(7XK>J%e%S2a%Ut(i+)PR4:(OOAYMEr40.9%g6Fl*LW$!)WeBStc5iIXbCE=u=,^sQ\(
^qI/>&ksnh"dG[:SQHmelIW7`io/Tjoej2c')0sXTDa]AACpkU@W6c9?T*rt:.hft#PqgOe9t
=.:`ao7>PoPG($TrU(gDMYX$be($b*@VpK=35>+aIk;*Jpg)eac-r6VKAEf`b9-+1lDBf2Vi
.d]A_+E'"5QeIV0ukm]AYDLuC$oCk:;U6l@ZMrOT77rAc&ZK/!9U&S,W&>YbCKJ'&14TA!4g8E
O6@(9.6#e%I/6[&m@Zo`Y+9AOpa[2-&-mE`Y?17(]A6RUKZ>&+q(u8>rniBe*[XbN(R1jS%7H
#CX/t*^;E?:k@Rm;PU5f=>VF/fVmFD8`hFbS)P;_-U/=5RVBn\>6WjEDRUl0$3,/*0r(S/5@
iLa#1qTRT6Et2nk`7J3ihZ1qHL/bpe<Ep^)-7A:=PBWD=ND6-\=>*I28V;/maIW3KlRb3*O_
qJ[pC+NM#&ug-VKR#5eMJ\Bs[@hpq>/r76hOGMb1lrWJ=CSAAch$W>LmGA.WO0Tr:QL"!^!4
3GO]AocaS(>AL;MiK7=STd5Uaok*iJacNL`(2`L<:3'&L<O^?TFcj<ejn@3F4'.6^Mdth9Wr"
=tY`[:WLn/LU+e]Aio""!3[28T.M_L=>-nYMlg^%Mq&eirYJQAthgU[r9aJ&f\ju(kt[P\erj
Ra6f>J<"BkdH")pKZEJk,3m0fq9YAtAiZ2^u'iXZprbeO6E-oIpMgl:?O.L.+)Ba:h#fd077
GP4hQ<EAMqHB&-i#b.([bB#A+SYM\_?cL3$[jDel0ggd=XXs;2!O^d_Apmsj8Do,RL6Y-l1[
lpjhPTrUKZggJIHHgT"mHO-W^,_2;7HL.10o9&3p=[FX-RS+/qmcqR0b(11#&]A+6@7l!M'F4
IGg\^e6Hn/AcD[>B7E?D^&'s8);oOa_m@-^A(i)ba<X4R6L[&IU&Or4D-maRc4rPloc9Tugh
J>B>nGobkNV5TC7X]A@1+O3M0m`fX`oO)h_\5s1p70Oi%RBA:<LRfi+jH$aO77QG42F)$M.Nk
4a0K@4/##<tC&N]A;j]A!BV-*K-L/FtmsAF[S8)Ln71=`&.@lS8C#KB^aMb\o$/b@f41@Z!=I\
`Orr-a#78/IF%AO.A6aMbFc[H*4_IiSbAQ=Tcq>$P(Rm>5m^'9TC\aUdXd2f<<^:qL'>6d>2
tTPdf)3=m@"\[>UJs"cS;lb8RHDrF5Ve)nl<CIBaAHqs2@JK(<]AnZd2faS9Hr3[rg7,l-aKk
!f+F;?JGNWL;PeX,0/`0jYO'sY/8Yn4O'"M2Ism"&\jC=@76_Tb4_i,8nKk^Od<)*^P)dQS:
TS_dqnc5A]A?ng;?3^pGX73Nr-:W:C+#2%n.l/i:W)u,P/:pL;;F(^YmFY]A'RjEO(7TS8I)jo
X&6Di?!\WK^$I9E(7J0ccX?)*_SBhj"48gRDq^2oi(_JiHnB5EF]A0QLH-7K/3bE<s`?jAAj1
6MKt3&+ILp'7i#:'OcV&<LSMM6R%-qKXdp=`_ElpIH>\MZk>+62dYQ'Wmu*EJU]AVm(jrB*)W
>#&Hh%g)GJ$rp7F*J4Ng/-/\(WqKH,'$0^<nY`7N$//m(HSh>psU4(AGD!<~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList/>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="196" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="597" y="20" width="196" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report6_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report6_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report6_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__4CC946F8654DF6A300464000BCDCAC7C">
<IM>
<![CDATA[D,u!_;V;sQPEH-a\n[&I<>j@EM?oZ2VI??g;/j`W97.ulj>3^#C$'NI>++BOW"^G^aXGCh='
8Y&SXI>76-3aM1ZhRp=t4-[RG$DoeuZLOh"g-7oBj6+kPfnED]AeeH).JK2`Bk,H9)iPN7L1c
BJq'B^6L]A-^Dra.pp*2_V[OF^%p2$P[IP]AsN2J[*kYH&Fd]AqG>.TNHC&T'7tnWb'2<jG4hk=
ps/EZ,Kg43&!%J"jrK#J(f9j@Ql#KTJpL3o"p%^>riq$pN*>[$0fpD'-k@1jl9)3ipum"&Sp
<b]AdY%N'6dN*RLW&u*UnsL\Ou0.3nR<3/&Ceg7e4j<LIIgn-l`(>of*$Zil#$3mOU4>h@"]A%
mfpNiqP37XZlQ!%RhVq*Q@A57pKNarVikRm=sj%PaPHmmmA*f=OHki]A(4ZMbm\&HT0GS"u0f
t`FU$IbKJ:S9TYA`0=\QVm4s+<Yij$4XGokR@k>K-DuFtI:ER@CO:^l>3uY*c\k1f\C<=@',
bn:MkXGXf*ZCFSE^:!!8+e18f@9-iH3joTO4^Sb60@F;<$0eg'<XD*"AMR-`KD_T=dDp=Y^G
&Bo+"R9l`lL`<29.+[fK=9PjdAIP($@;F)&J7\/=raV_m_a[=9@d=Mo!Re(Z_ZHDqF'VpUKQ
T?UfQ!Cd^@L!ql&.+`9)S2YuGj%CH:;?9M\I13dpV%IM<%:MeYjQq5%=I9dn(";GGj)9(Dha
d+5.C3X"9h?#T=Zr_ss$`p7M=^<3Qg2crscOT'kh[e?Bu70m[5^*=$7=gOBg*N6)]A7gepT8Q
%Y8LCaA3Rk,ttaUbd)'9I:_4%IH"T10SGa3WTMgR,_rK%B$>^.EO^Vq@qorH_hu/n5#eZudd
RS_6/'e)Cg&<EFuLp/!:"M7eOe:o'H9Y'+/ZggEQ2?hN'TcmO8QaM-FHK#//e(?_f$]ARW"Da
hgaYcCeunN0TPRE^aMIe\5>A2NP#\hn)NMr(du^6!sF3TFl'u9sZ@^:);j-&SNk26)(uoPG`
RD(=?jJ89ahl;tch:qE.=5@p7g!8=*j27bL[WB,*aN/%uNn)F45&=L'6Fdq4l`fbX@uq.Rj)
MS=*N"MMKfUbL%O**e9&e@huo%@fo'l$u%<EL?@?9)HX9cEXkDHAQsS6X*1S[lFlQ'3N/]AoS
CO\@]Ag>bno[AICDOK`9C*tF-DbIR6WUh.Vmi_hXl(P(fek-q7kip1;^e3h::D(P3h4c2k]A&L
ZIN..e<U=RGdG.#O^cQO':6P1iK5*Ti$0uNEhcY"1BuBd/eoa-]A8:Nc9,^84&VsM0pTb)s<n
:mjF?:M1@94/ab%I7WgIql8\4bY=D9R%\Tb3IJHOdCk]A+^oKT#C/.2ce3f9SYjl&A0C@!/Ap
WXR>7kE'2*RfefpW3-C@>43U@9DTcrQGVj'41)*6c6KN%R]AqXWZ#!t1/&!cSD(GJra+Wlk^N
UG@<nOa;Q)3[,fpAB6.VkP.?D5tQ7`<F8n(qF4r(Hjk#3cJ&a[*Y^KeA1,IYOSKLkLV6r>PB
j4>-8c*$TStNBGEn;&@WrO-%3,_dEnk:ojQdi1NQRF_D#L)OXRqfPk30D+7pq\B%be>X$M&5
/@;48$.NGNF[\\Bf[[a3$3O&U=(%d*%@E"tX'=h_^^Re>`@`?iuqWS>aPi>KPs)(=qX/b4F:
S4T\+1n/!]A#lLK]AuZAKMXsoYMlE&/o=A;:$ri#ahIO<FHg?`e0JWGsrU<p!-NsDC3-mIFfI5
SroQISSE6/pIG_4oo+O]A(q.c^SNp;eG`Duj$c?$ig[Zp>n:#Y")mINV^e3e0J3%\6&)\dE:b
V,NTR@'q#qX^?*_2@2@rAs\C`&0NThJY1T5)LnFF*k&dV<':Wgm^b'W"]Afu.*'O1XJ6\?/+<
iSu#IS+-R9E5b*+39`VB7c(cJX8EV-lf*Z3opuK/RAf"u5`hcrc>.Eo+/IZaX*a3[H`L.u2K
9`\,iLTVOc=)U-9N'@#%W$8`go%aDq^$tKuR7&\-\^PT43p<Qkp\)Rk$9J^:-:8CW8\="nQQ
(6(DD2Y5!/SSPWI890[L^75o(LLh/O4d*lGjXmmM*l/Z[(\oEaWYdjdY+#Bn*HEEVaFj5N0B
\0Z,qc92TEkOT:9`b[:fLpN=`YYiW!^l<&2G5_$nO:^+05>'OpPK]A[7VY$qp=9%Y[Kr/6c/>
m_8OW]A"!F#HbYVR2%iVtl#6']Aad(aSbX9ss=WA3.eMhca,g5Csqb1VV[)Wof(8n\moc^-Tj+
.)5[9BZG5k'J',?Ne[rr&!9QiN;nD.\F'UEj8,lV."uh5c_%]A*<-7]AJOtt$!\f8ZW"<lOi-,
.*O/[O2"/rVQi`Ikj)N&5V[XorQ,Eb"6,@DqftmgW4A/bYXsZm^:+mL'cah1"1^=2d>X+^gj
dNN-6i7K+7oRIYhH'?@3IWbh>nA3mr:X/Vp6'KH5q3Eo+)&OVJ[#!,Sg)2@'W9^8)uor:Ksa
%W[V!iN)L#3HhdG/l=.))h[q9d$h_\LVD/,:'e(H=.D?$KLE8hV1U_]AOH'4^ZjCU.NYSnTm$
U"p'RpKbXq.d,FlmNG^5AF4n;$NbZ^^tKC2@$T_[B^_f$G6h*s^L-CciJ(2FS<Gj%LOGop!"
AB/oLHdHe4R&kN2<N--YFbqJsFEfIH.*d5aSe>*ung[j'f(2/!W-':LJTM4;s)p>UU>BJ5KD
hq)J+D[.:g<%"0:4\K9(K(LG;UE&<Fh?oJL%G?.p+fTD`4P]AnmrneZWtQQQM+FOSD8"o8Z9c
p:*<@#M#j]A0Lbe+R&^d_d\qSff-,*pPV7/BA\7%RhbN9h$R*Vq;/aYH.jRuFGFt.>U3(9mT@
*orCUpc`58iDE'!G#aV;+GJ8!\edm`g?-9_o!%MV1RM)!i>9$<i`$^Ij&e&pp,\t*`<?>fSt
q@rR!dhAgq;clIIgKZ96UHC_)!c@/@JEk^3$YoS-ntO:c(^oi/]AA(^TX;haMq$fINT!Gh`Hu
QbTFuEE_5u!ROd_Y95QI/Y,KeBZj,J^rc*h[Oh>HE@)^F+;Ta'ih#7*fsBBBU/C.;/@+GLMJ
^<03p]Ad$`Zq[bH:qZ$?'.7A%b/5..0i.$&YMRc.]A7^1QrO^n6RICF!b1[@l@_B'@X#fCTSZP
1k2)m;5n3h+@S9PWFoRqg'cTLYckL.%%V"M?DiR<mC-1"(8k":#?GY4S>@Q98\Q'R.M-O:nd
p?)dt5Z4Fo]AQZ]A>5UY$`sKdWsg.*>g*52)=a_1A''&6!ED2,+_DIm*J/0XojO:BT/>TYmQ^<
\7TUXqb/@Z"8''%SAnTS""R2Aj1I[jb7Blk!E'sM+o2CTd$;C7pce~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand/>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList/>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="220" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="124" y="20" width="220" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C_C_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c_c_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[1143000,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[457200,3139440,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[线下产品月毛利分析]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?m]AJ;ca[R?`Pd06DE&*#RNqmKn6H=+bbSI6^9'%`2-qc+s;MS$DpBg8@0iIYlPGo![`eb)2
BM7,)]A9j4qStqZ!%GH+G@.e-#=2:#rFbXVuK#3kfiqgSTjQ$S9+,mhK+.Ul!F\^2;5]AY1B7D
EIf"qV!8p"U!8)7$e,/tRmY1cW!2/-GLd$T.L#Y=TecrNbe$M\7A/k[F_lZGjcW]Ad$Huh=Ge
8?ce:4A<%G4r=c>@35cW:7>dq@&O(@rF#>ff_1B1?ct3oL7i?L)S^/'c(;.SBe.pX%O2=a(%
Wh.A8LhW,.d6bb1]A?Fi4$[T=RPB-bQ48&'0NAFO-JJj72M@om[e;X[rh5\9IUXGpuU,jLf\Z
9i\>jXi9cV^"$'s9[.#FIV'4di4C`.[EJ[Fgsm"4&=%3>FWtInIRVnG;GRqk>Rekd-r#t_a+
S!kFP'$$.qAbK(WdZMG_BsbUGCns)E<o2U3)c)-XsL@H)SIREJ<?`^UX1sB);E,@dH"EI!0k
)fs6MoQI\i6ILpA;2@o!]AIrg\B)<tq.Y90"]Ald,#/7Y-.ReVL8;ju#3S<:\;.[T@b+;_);1^
;YY4:OCFWi-KK>Ajh8<`+WduVL!9Z15+#ef1emKhUn.AJYrZhK6I6mbQc+K=oag2D,Mg/fbN
Ni,D[Tp:?>?),%Y1deC[96$V[#(UQjF$*DIm(_=JoFm$41qU$HPZ=HhlL:AnmqE^n+15>rTH
E4#so_Do3jl!e=C;cdJ;l9_^cJlcdUY9ELR;;fY^jA)!s$LJq;1,!]AnruX,,>)2)k%Wp:s<2
$T3PR3eR3X*A5Fdqq_G4l!c=.IJt.CW9Ei!`ec,tsp&^:%BJ1T,XeNCN8"s%AZP6.8h5C-Lm
aNN>u#jH;7$aY_OeV3S9cAQeJ7Oc[O81l`(3NQID<8(J%AW4>UT<(!gQDqaN7@Ps$1r?lG`p
BAK!ip)6.8<XQu%N7o%:G+DXPs9?6%qJXg1m599;E4juE2rjsMV'1jEF,@rg7?1k-A%XTK&3
D*NMaAbd>KIjkSeS]A*b-hImnZA5.\t/OFS/V"1(%h%GGNq5lY)NTGtpWQ":UG=n!Z(\AkC+H
MpmV6V[LiZB^"^^/L$(U=CA);D&dshJgOlM9e"&lP[5_LjNq^LWle]A?i=5/OSH8h$`QY#38r
b.f)FlG1Sslcfo=g^E>ar^U8d.`dO)_+QRC<aoYkIV7=8`ZAB/Nd:Rp9"=hp=G>.NcLfWC/o
6D%i)X\L-SnbLO[R="$HkNkgOMrH8\+;L?!k@$'V:^dO%pH4atUR(A-9H2Ig!R[X.eOofEX8
M7<#9'c+dF\]AF@gS;IEhV,KtDY`pLY"EHKX(kLVG1kfdheF50,;lBl_?7:p@op"#m0iY:>rf
m'e:7s&2n>I&>&m5?QrOL0>!%#IH.j6AmEJGIq.hal'2`>3F6.-a86M#4;G.X\'hmJ\]A,*9j
<+&O3?XVQjSX\O^K_`X:1G_WKGbpDJi8mDNeF4JkH(iV!"#i_J=H"l'\/Y0d!H;o>^RPB83k
AJ1`7BPA)%;!O?/"$+T_VTu\$IuEeu92+BjQ1VQ!uY@_:e:;s'r0H!*)gBH@h:ubVX!LKu>`
HGT]A@cVlj1%6c]AgjM6jc4SGcRf@"IoqY%DaA''B&t+<HG:b?qHD-$EJc#r-O&SO\SB;f>">b
=O_M>E[Ul8p[r18M5*'`L##YX,kU'n3j#eW/^,b;mlho[i#<tN9rP-KB=\[`>mt6%&5T*BSW
<F]A[2N%_G'+$:_+5k.qGKtWh<gc9n5>i3ElJ$5Zh;qp?MA['%G-U6Ye';[EX"TZO8ci[_Vi!
-_FL.717a7.007n@2)1>'LlLF7U[!#@2)1>'LlLF7U[!#@2)1>'Lr*q[#$B<fE7-/XFt>[&G
mRtG&'nL-2/Qijk3I`-INe@:Vr=qa2qdU1Nj?Phc1)enad24Q@0YErEf~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="267" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="687" y="43" width="267" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3_C]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3_c" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[396240,4084320,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[= MONTH(DATEDELTA(TODAY(),-1))+ "月品类销售占比"]]></Attributes>
</O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0" showAsDefault="true"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m?IKLdWZPK.G+6gSiW^u7*;5i7]Ar#68XQjTQ5FdJ=[C<TQm%nIP'C-+jCOG6ZmP%CK[-j8P_
nN+Mdo54XAR7`')#=i)(GuMO9u*fAc2iq45\pZTC;As]Aq<XBr]AK'cpAchuETu2R&.$3/1h9A
r"L8";JN+WU]A[6M/kth_@5bJWTpB2O0jc&iZ*]Au;Gg*c0)>m8hd(44(EM?6_.IQ8']AmD/F4X
$_ds,7AE"3bL\Gj[TKV4R7.XN9f=V\%dC"(b(4D'mFC+a$.*+e"f]A:]A-th$B364`<IJ[WcV\
2Z6tM*<cUetV/A\l*#Eld&W?LKk\DFah(!k+R`p[_j[kec!od[g@lS@Eg/t6i*D1Qi_*ghPY
:a%o[*]AT+1fH7UHCqfiJP_Ce+"##1@:HCMdkg#XV!*;=OPEirS1e\E?Vi#MBWW6uL%Yni2=3
!6U#4?:l61$@BBB1lHU#OMFs&/(^*9.GS;1dJl79,<(?6pD4\'S9KcT9,(!K#d(1+YT%Z):+
TL(a:+>\Xu7`UmGlDB[N\O7`c!98[0A)&bOrcK$5bqTL_hL>"+sH5pp#Q,^F''HBbn81RRM.
TE`QWQQMZH\+]A&@ft\=8OdiS_(#a%W2lQ(/b=du?HR`6F&Lk((:7K/cnseKnZ57&;bFr!ah<
d0IoO/iY<7JF@?o-LH9m9>[/kjXNUj`L<mo7t]AFHCfKJ5P[ce(^,F)RVnn-^c<Tr4VV,\8&u
*QqhZjs*l0W7`,tmhGJc;3OfY?tG#t5M!"oVY\b#:*eECY5Ho>hAp$A)?fJ,c>`59;%dd[YC
#<_+?eAm[l=iZ(Fq6o)1eCDn=1+*\bWnGrhe(IqR<6(LgVjkX#(Y`n3M&>b+tRYi'^q:a5BV
J_aRqbACnr*Z?cXkk9?$iA/4HoI[[(O?Z[)AD@OL\F;X#-WUA;ao'@dBPM6[kWGNH/Rmg2oq
UV`j(Xupr7YY0.CXpN#l=G@P0eB=kjiHh^KG#[eFg&7(p4?EWVlb+Zm\,CjhOc.T%"Cl:7'V
aQALYnE_:l1uW>*$:#httYM[g#L/Se"OIO$e/J0ptCC6JI2-FAbMVe8C61iR^&1Lj@=HToh8
:D8WqV*'&N[BY)-B/Ne\CqLLUa?2@hBp(L\VWF<N4.XQ\Q6'HLEF<#C^STDAZ-/Bn0$`8,-0
i6>_j-ug[<0SO$g7ihaj&rX=eRTtAg!e2/?_(&89S:9mJY,NA'[#]Akrt49q,T/-+'R1NFg).
+RCV+Ob_qT'Ca7L?d5;Z=gi.+@\VgGYI@VL[SG\7"S(:Z/r!+sUbJ`9Ti;Gj21ok8n7VXNB^
<91sj]AJm.j9!0ImlDFpkNZ2EB!NkCc]AY:%>G1Rtebes#h9AbjOAO2eA/s)^'kYY66Yml7<lb
hraXW..alTl`K7Pc*[=2S<[*<so+^#l$'/fdlZC0!S``;PL]ARiSX#'2:X)RD&^V_Ps=3;6dn
,-Q]A!^L9R?I,AB%Efq&u$Bd?`e\b":]AHNk<'0@^<_YWRYior)IM(Z)Gbb+K#9H2u^QIb8\d#
2U&(baaW_lFr`>#W=Y&X<.r*(qe\@"Y<;eVua3i3rH3rofQhk4bHIhW4+LP)gY!5i!O:I<*f
6jKW""TVV<Ye3%p8M<H_O"f^hpoufD2a9]AW$%Kl+cTR^fdhXrIAOU9O\DtumO$-D7cNAbPhM
G8?Oj-,3un[S@)KB1'-XfR#o]A;fcJf!)T@d4fgBmirVFM&_l>Ieb@)[sj:Cm87&A;:6.@Ys>
o6XtF7+.1TCHn]A\M4#hkcMe(kr('6-B2KR^dtF3VgOh$cl70R]Al><:3Q*B/_bDNq5dTlg@_p
S*m1e4;[%#7ugft(HS.j5q]AFe]At75)#SE0J@Yq?ig`DMD.q#ei6AuZj]A?:b]AI3LpCEpXCL43
ZQ`OJo^!DQL'(PuWLAWBot@Ytq6>E"E1M&-YoB"]A5g7;%Nn.&-YoB"]A5g7;%Nn.&-^J]A2Tj>
+a"Zkq'sk]A;S_J$HFp^E'rB.!#,g)_;BP8e2"G?`@i4Qj&Bd"Hf\8U,Um`"Rmrq=j,IfK~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="200" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="359" width="200" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<Listener event="afterinit">
<JavaScript class="com.fr.js.JavaScriptImpl">
<Parameters/>
<Content>
<![CDATA[setTimeout(function(){
	$("div[widgetname=REPORT3]A").find(".reportContent")[0]A.style.overflow="hidden"
},100);]]></Content>
</JavaScript>
</Listener>
<WidgetName name="report3"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report3" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report3"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__9BB2985780BA65AD1EEF95B35E198624">
<IM>
<![CDATA[>uh82;Y_49[sY/7bUZq=@@3Qs8oi-LV(>=md7MS^PXTAnS8cRr9UuE+)&5l/=h[R7^`!?pnq
i0:b?2pNUn`L.>DnjPi_,Lk$6/0AbY.,HkFR&#kI]AX?q^n/Pl&_RoAh0ubJj:G7[(gN-#R$G
FhIDP)(9^60*;i)F'-FTbG?@>&E\t*Wr/aokM@/1Q)>VXV5?7?@CRY:_9kYZtV62@DA@-oVn
GRWr1O07LG>t_:cTeT\?R"$)(`KQe",<tI5s,8.2g0Vm&nlQ/"ObNNZk"td@nJ<6_`[C:7<7
kLIj[#qE>?Am=Y*U_]AF0GA=<L2r.4c.@%[i1_1VqBMllF16kJAAK*eWdfE?033,X9D.Bq*<Z
r,bYAlfurr/EL:nN.jI6+6D"nc(k\U5[UTLSlh4'ES]ABhN8BqUDL55aftgDA=bp_hH>DLcO]A
"jFfduJC&Zh_tcsY.ENh9raC&#DkA*LMY=j>7_orPP/22?HXT"K>HG`qZ`S3i+tCQmM8">,2
"2:E]AMm]Aa3]AR+qq5Y`1VMcKuC^dFtBm2qVdi%jS35Qak1pdYjW_]AeQ;a3GTk:Uh5QadLrGVT
uC@Z1)c`;^U>l@@P+@(J\/^$W9[#bE-q;u=YR!29V_;q_mOsI-q;`RjKTKM*l^!8'Vd]A;fbS
Y1<l7a9Or@2'UhWVK+&nh*qR<=%'kYXb4@cY`G`d$$@[+XA%Y)N:P=-(:q7HNfL_r<MF))&`
A>f;8"XS2Yp>WSQa`0%oR)Y3P]A1+n2h*ptpkA"2)0m/jQ*d2a5h6#C^d.m;2i_K]Ae@+KH_[9
l?]AM"NP"J&t`;6`:MRd>Y&+DR?,S-;fh$O51V2<,SCjDW>(f:^9XI]AJP#k3lZi-gASN44,n6
5EATFt>dL;Q.[]ABs]AC7prlR8`3+^UXTr;J=J6*XI:)SL+1I>h.&(p&16o0%=6-["RV/l9Pfe
@p7GDQFV$nTCK=b%iA$UF,["VC$RP"R91F.2DMI0O]AYHnq6)3![M(0C%:Z+d15^Tj,Ze?MdE
;2?YZV#c)&nQS&091p(!]AagAY`/HFd!4e>I2b[`&d7Ce@@51.RFDiRJNZ_PY>Elc%pnIR3mJ
ohj\6Zpa`:]Ao,+TpIKMubQs8n'DF;'2nUZ#-VLem0r-i6[SskC3]A(6pgYa=s8?KKdk>riI81
&]A8;<Z*bpYB81Z2HP\l!UQQjcXC8VIsX8'qBL%ZD;$4=-#qjI38I0\b6OH_YtNRdDm`CQ+ca
kbXn6&,&BH]A#d1r,@ndk(Opf9:<Uk<'U/0U+]AHMt5L1f8Up*#eTj3?^45_g^phN2'.hU:`dW
BkX6?@gNfa6$DKP7(\\:T(Z05Y0,BFOT?^*aSrUs4fn^N7Zc("DhnIqLY3h8_/Ta6,XanNq^
A-O4XL^kE!PJAHdN/Q2h,DO.JKLmW?DsV%j".?1`8:pR308LReIJH@M-\MJ0I%N6L&-8K:KF
dpGj[.i`3K4E>=n2%V%Ua`m65I`Fgr*s%$IHRCg_O/R1UU7?["d,9TZlOJIC:tYl:1IUW)CD
9Kf0B9.p+E4&V;U_V0N:)uE!1.@[dZ->M4q]A?rFnBmFF-<3L<ZgN0d]ASc!QtNa2/CEk@6A&4
%c$)HH]AYPXa,1oi2<GNW.C[L<T1eRl#'=dp(ADRp9kLqH%bO;SIBb!*[SXMRTSCYfA>nUL)^
Kt!bel+YJS=5;1=T\:Z9ZK0U[8sU;T<TrJ@%[JST)4>(filO!UZJ1-E1AibDi1:i3a5%q`@Z
Sj9a7>;,(85(EgQ8gH@(=ipZ4tC5QDU9klY,)kP]ArNpd?Mm^XeqI@.SQHi=\_pLM5FXK25:G
U450B_q08=bWb@sEQ]A+Y'Q+--Cqf-l?B;grndZHqQ0+[eg,6(2I=dUB3#9!0K"9l[J=%-oCa
aomADT5;B0/LC1[1&LfrI(4JltH3Gs#%A!Kb"<$hEQq/sQU%QU3?%RF:#F29Q&0N)JKFoL0^
4-`mBKXbcg3\B-^QYio`8.7Pu@I8pCT#/GHo2jlX!K0(qI3rkd.>i[7P.I+:iSOhRB&Q&C#G
@1XI2r"C82?P*#eiOnM3lB1l3J)B"_S"&&0..BN,m$;6*HBh"-i!qG@uD4#Zs!sc#!EKdZAD
6/`1JJ\[&@B*.A.4<@0<"/1m.hE]AmX_Is*e`-L5Q&BG7cu,R)>JbX:o_\D=#>GT#Os#?4&73
+LCDj$UELchmL7<0&Non0$5<#"6_fL?]Ah!7lE6rd!^_rTPWOI$mr_r[SnBNGY2$PUc0+LP)Q
Ta&jgnTHS5'Meg'#W26\sP!W9gXY`>Y;TS*.DGRDlaAVe4/$Qda[0/d*.U^o8*jejF:`oo8a
qfWmsY56RDPi&J8lY,ZT,Le/g:U=7$e;Fbl4JugS+N&!'XNf-W^:%9gR4^!>_db8H=ESU'Vh
!b.n&F+&Xno1S3qFm4EKnGg3T4_He+cHoq[IF+%4T$>\T\)\^`"i/B5ZWDJbq9K"I=`<@#Q6
NoOP;3raeA"c=oP"TF#hh#f$CHY-e[t*1VS5T9e'tqNF&.c43en5,g%?:Rt%.G_t55t8^&S=
.Di3!%4s"sb#O8nEbc:p&Kp=dG'o+g$R(EUjI7DSF_D)Z*,SP_a14bM)&3sh-bK&=CFIeYoM
/65a5#SI1tss)Eu:!&b5U#[2sg.CGHO4+PT4g0a$/E)=DV;1WLVFMfg?g4s"r&tY\3R2f_>#
js"MJj.TQ?B:mQ%9,'+8%I3q/YFXgfleQuVomg%`-#MEZ(B%W!O[^'#.pZoN-5p2Q2R#,W5!
eHHJ:h="J=;9fpBViQ)^M4>60?BKhF+<%R~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[304800,3931920,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O t="XMLable" class="com.fr.base.Formula">
<Attributes>
<![CDATA[= MONTH(DATEDELTA(TODAY(),-1))+ "月线下销售排行榜"]]></Attributes>
</O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style imageLayout="1">
<FRFont name="SimSun" style="0" size="120">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[mF)"jRs,hPn7Q7[W\7jfXUE8%;Of22<=tS!]AlY`JWc=tW^0GlX7V/W+*[J\SN_<Yl17N?YmT
`t3V%Q]A^M[8?T^.$WnnHb^ZI>KP<4JWVI-;253re(0TkGRM=I!L.sn'C1qk$5M:j6HPn1B7E
XYuf!Q!:Z9r!&u5EH.tAYj1tBi!/rb#Hnhn);)^.Fq\\ti=7]AKPKDSi$4R.3NROFmO\T<g%l
G"$,mRZi_"I%^\pe6d!lHAABHp**ENX$*njXIc9*D#_fGkik7d;`V'"1j'J[.q]A`OJHk>3k-
!k=^W+AY(&n\f4RXg?MnYrEGs+H)B>.'ji,!drN3;@/C2-nlp&>F@90trYl867P=Jl;ZaNT&
b:QAP`OG42:Jj&Wl`kl>]A3WhjgI+4aTK"e3>8B6>]AY"".<#"O#@hrrHL"1s6SIMK-1`$kIdM
gb@oWhB-BhhqsLoZ1r80hAk1tSs<X)A>X:;2H_'oHjnrsqS_GYh&+8*mrTqROtTO!nr#'<*X
%>mb?.X0h:TE(USp$0kIs^%#V[Z1j_>*J069Yk\^m=)=k3*bq_i\n%[3pZ1:iL<O_?S>+Ob.
J*)(Z7ggEpnt?=?6tUj^#JPJ)?5g>1BR7K?+P^uX:NoMO:;+63c&ZlK[fQKcIM8+0L&EA:eX
C]AbV\?D@B_Pu#4<%)&2#fo-1kn0D!Xl;RP.K#XXBCSPseJ.Soe%H%/!A7&O(7q,<VD<>#87f
KoIA1A,B-Bk)';b-EpUqi5G&$XZ+AS?'qC$!d"('$_-<#<$1`$Zb>!b9AAjb-#[uI9J?pSNF
P$*9LtGS^!T`Wp34q[m+00J6FZ^'LM"jkJu)dJ'C7GIr*JjNF^?D7Gk;E.q<[U.QjCmJ$-]Aq
C4EiOiDoj&:G+[od-a=3=-VD;),aHAm6VAf]A,p[fmGimqDA$>c,LgOsIOM9foiT'RK3Qo&]A'
akfELKCac!mkIg%56bAl363c6?TK>6tq=A3_.rT:UcD5..UZ694eii5.n'@a>_Z4RQot9C#H
.62^L[/L\2gJD*_1bR5]A:sqRa$jEi^kOma\4VJTq8'^NX1'(#`1Y3ng5b=l(\kY0dAdRu.[$
R9FZ.EmCo%B+"3)Jr<uMip8D+^2$NC@qh&OA5PMOe-T,'G/SJ?F),s+KVnJrMi&:(&K((One
J_\HZa"b+)o`\jCcm_"lNrj4$nY8?t9hsor5L4?74!]AQ@6\n>1;,387cZ9Y+*7c_jCPIbYKL
_d/U?K/0&!11>Cf!)jOM)_LT:8klZ;!K;+X_f`M3b&$GT!T:H"6p=95H*)u*"MEQ))TuGXW\
aPAQPbJkg-q,RW;2S89U(jFP74Ci+MGf\5'W(h.MAR2Aqf`"VU?i9\LpSTR.+#+"&++"dGkM
FAPQQjsU5T'5U3"U:^Fo0@bp;$lp@;4(qk^AUrr<~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="207" height="20"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="38" width="207" height="20"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report2"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report2" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report2"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[2590800,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[1310640,14752320,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0">
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
<C c="1" r="0" s="0">
<O>
<![CDATA[2024年榴芒一刻线下销售驾驶舱]]></O>
<PrivilegeControl/>
<CellGUIAttr adjustmode="0"/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style horizontal_alignment="0" imageLayout="1">
<FRFont name="微软雅黑" style="0" size="160">
<foreground>
<FineColor color="-472193" hor="2" ver="0"/>
</foreground>
</FRFont>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[m<MbuP?HKi.Z0++S,nm5%`8^6<(Dm4#bRlD,"2V;Bi,Hn#a#`$JKu]Ap2TVgf:eF2k6VHX:-*
[H4)C:JqPUJ9)&0O;1D^WaKrP,scm`rf1]Am7fTce`H@[J&>#?LOHF?>^_6mp*&mV7#jWO[CM
'ZrWZ1Bs$r5]A12B<F&fB*QBkhUd6e0:P4E5)f4A)O&YEPDY5j7RVo.lhhm[M/%rN3_h;hc7p
X/te5V,$6d0M7PLq+(;r6TTR#A/bR6OmnXs)`\@O55,2A&l'KdqProHhErnn;-`=8r,.`ij`
6,M&amOQlZe'p$d`?N?]AQJklf.YS9JJ4f+BT=X1RZ-NETL=\eFTMV5pd&M,mnnZg'BIS_eSf
TpE_gltXddh17-Ee!D>GR`CqXc[XO:I=6Qu#'5'JfpS/LR"9Og"UPmJ??Geu'fH0GUguH5cR
eV)+M]ARIj<scI5W\(DLV$'!C!l0)$e!heZKMa%Il@!nMK7l.s-C_iIY^HTkBK[:FRt]Ao]AY`Q
)=1MSrHt#GZ;djG)3:oOYJ^\3Y]AU]A[D@?d9A03iWU,?ruO.6/^\->DmUbYf,u)]A)[g;G$_<T
SFbM39EbHOGAM[3M!lk6G+\0o-ds'%VSPr"]Aig))W-r(!EqU7a.%BLF(eQ:b>Yl26S(kAa;?
AsY$)RHDU^ZAM+*u>KfP>.5bqkKBtSXkkj*nZnMQS/lF?!3bq7IhZ^qq)8QM@_,6]A'[:u$mF
/Z?.Eb9"Q4aO$nhs!5U$l;7Bb7ldDun`sX>P"pGYLfC1c/Hs!NQ*ceoP,^.JL\/l-m[4e:mP
CAJ0O[T`g1G`X>:Z6F49)_dR:=c#i*Dq2Y9W@7DCo0<2XtBOq\*:j!K%L:nTVNG/)[6?/AYs
3\p1Ib>]APdf&=p@pgBe22/,q`(GBFZJ-sL\gKGFm;Dkscdo]A$4'9GdI1r9.L+*t28]AGl)t$5
Am[%PkNt8\qCd;F2u:_?p(X]AhRMccp6._V<.=6\moRXoHuE5+?2tRIZN#"pfG[,1PL\-/n4A
F0:n^9X*emHNSX"L^W/fjDbH#36GDNs.[J1(MA`f,MCOmmqBhF$CKEQR`PtX3b"^@:@8j!UK
)08)V=fMp((5mUVYI>:?X.1q*_;bhS'B.gGl)?N*b%rT;rAIR=8+RAen*@?fY'(!)nQE)QHc
qZr;qt%IK.RDWBSq`4GeNHh(qOJ4CRnh%PVN'6Z*E]AYc1"eXIh18CQX"8i7mN#6kFq$IaB07
TKK4i`3QPo;Bc:qPG"-G96]A02)?NcP^`b/"Rd;8pKcFBlY6c7Dd-FC6l;be(EOB=`[367Yl4
O_Y-AF<KTYC`]A?Xqo0J,5D%@2s%nANimoCl;>^dM:A=B^8S0r.>ki7:ng/Z$KjBC;e#HKBJ<
SZp`.u@.B*4sSls7_cb:h#=K,F4[3n>I/n8Hgh%W;IIg?ER3q/X53o"e;Ct(81''E<H4Sia,
Ce?HUJ(joL7ShS.Kc8:T\O@'l.nBCWAc)s.O%OTsP\n"`"q:16WIbIQ72B!dmel=`;4rhB+!
pbO5MtrW9Y?XcR;bRDH_F3e^p,;c@j-u4-3U"G9Ek@!r2FmpnRTO\4*OS2JSJkb\An#0E9;@
(,RMm>gU@)1hil;r&eo4[31oKD;^e@'hscp;\+j3?M;F?KW'o%R]A7n^9QtJhaCeGkH,YAIT[
NRU;[m/0cbOh6;%7*KGgT&.%.6$_L*+l6PN'hOmAbDGm)G"6Kie=kEYm&?$KsbsEe5Tr>(d5
IL>iXi\5OPt'0<'R]A>PU(<K(1u2i9['[RpKARWkt$TiDL>P'e)G#$A0bM%Jn+7OT:1p`gM=;
Y[N;)^k:B0RuU=-QnA.=S(8SY.oSEO*8NU.;NlD*Uqg3bd0=1%I9A.4L$e7sH;&4s]A[VkdC5
XA3S4J+TT?JQZk!;80AMGSo`B)#L-1fDq@s49JkEcgr9Por'R,/INSs.1/XQN"qLI`7$O`Pq
4B?#hrf^1blP':[m9JdqEH]Aos"8ImtXjui_kbu*`UE`+tlOX(oYWiCF"F<7LWT/b%-hASD2P
m6!DG"'?^h^#;B)D"LhZ6]AID/NhG39`J?tS,'%Bb;0-@=VWp:7_)p!_*sOjK1>,k0Dqm2"=F
jF!#C&[VEYkQ)Di[R9b&nd%tO/h&%Zr;p^)8@<9"+Y9]A'@oh%8oq=qitlPun4\i>/-81mnI*
ZL_mSW8$Z8+b986?o</<?dKg92,Ut=`@L7p`dknt0.t2e.a#DDNn]Am5.DHC6Z6rUGCjpn$KF
8iR>CS-r7@aRQ<r9"b'1slkIkfK3D_mP8GPspj,o`H8Z/G9AU,.:2#inj$"ndG?NT+hC6NQd
l=Xo)nMnoaV'pSWLa_D.l&j3Og)O(pN6rYae4Fl!Ae)]AW+qiA4UkqoH]ACjOdi^0*'Q>4IgI-
4%ktW>WU-O!./Mmhr;YE#?Ba/4GVnh))5=]A]AT@+F3>!5rl67U*Yd:P=64%)!G#IEDFIa%$nS
&-8FQD&dmoLa7WKmi$h;:Va:8GuXrY)-S=kB@]AR!)`=03+2hb$qXGi\/(E%7994ICN[;j8E$
Lih[2*a?qEb`mjnlRU9,$Q'8aT]A(bH>SpsFBROM$1Pbug/6-t(kE^<eK8")`R/`!G55Wc?1.
9l=\^r+C?$+YUfoK4XG;AS8r#CMa#Y-Tj<$hR<d.f_Xo6FBH8DHek<*i15@*5Me#sR6\'&.t
.48238D=">Rb(,d^o?e4[XDSWh7A4q06r&R7OC,e2>;1!A`qp:GQU8RPR(#O=`B(,D?5G(cR
B]A#Ja.C,SVi7Ve:&5lfMorEsNj[iXK(thlMYiuFL+ueV2(mlugdQ$;g1Jn!F'#5=3b=rLlPQ
'2+67Bo/eDll&dI+95#keX[[!kMWCZ%?RP@tn@]ATpZ</h8T8#=un$g*.93RBKK]A0gVd]A^:+=
*!]ARe\(t1%o'$VKar.%:C@&\"r!`Ps_Lc`D([=o%quUsf9Y1%HVY*VROuk]Acj,/))^h&=6J4
XJOg]AW*K[DqFe5O88an(FecR0ebl'Y+(-]Ak+,]A,IItjSeX.FR3KpIjP1`S!sNt545o1ZF!*U
T$e*-N6IRolc=Wn"#oqEeCDGKkBu./s?IVr!Ddg!BH_@Z1_H.*'qlDCl:I7#P>?iQ"9rFk#I
6ki*+;D66cMNa:*_b4M"RT7q3oF3d=U3EB@UPGIP'q3]A;W!;Xo&QobYBjCOi"8gCHR]A-/d1G
SBhUs)$H_]A&f$pdZ;5&K7c9DuO0eedUN9-i>(4>ITp5Sp6;>mWAMH)O9PNp@Z*U.u_K)Bn'r
lKS-5YtgpT\,I?.VsZ_?c8G)"6m'"9I$G5i*fq@r+4.T`F<mm^;EZh8OX^,a,AO^XgH:4KHV
&N!6c\4r7=PHZcuU]A0Zmrg0%;ajB?o.jkCuL[rn$[Qm2`A&eN,btWCLenX@DDfI"b%LcB7S!
Nqk1%j51u"/Jo-8XG6FOgT'&i%H_AR(.0!$7_D2FhgR*8rrND1_7d8(8!]A=AN#X[in;=/]A=3
:?5%jhDthXW([6cK2;_QirXU+WFBC6^)kYUg7@pXY[5!*VD#`%%1,RQf[bY!R]A&*ba+cS*WH
*j$H"$g(a>_MJAG]AaL-03b=a!simW-F'3Q>[&muqd(i)/GH[h/2CO(311E9eM#Mg/&nPAd'&
hF;O.9!RBlQ\k8!^9-La1YER?<G-,8L8K\8%:cA)@.eI;YuU<rP!;t6qUB*TSF4anlJI^O;T
ZbFE/IMC>ao0.3]A]AkB:W_GFXN2).i%&.j'6V2p1&)Hf\Du33A:cO!@`$V2HLS2uDO2$SKakP
:Qs;XP-?L$TWJfBFaY"QOl;m^o<H8>Q.uP^FA,pr9pFIj0<^J?HE=X4c\g+OE.tQ$rqn/`H`
3Io[Zt]A)C?e0G4a!>g$&&3#HOh9DH[_bab$i:`V\qG"eW!V#T(hZmHcgB''fK2iA#_Bi/!ZS
s6!TR@GZ_2is9D)e3&UH[/@@B;:j8V#G1m'!@@DW3Oi56n@m&%l7BJ:#G#0[?SV#*E#41a`\
KD$&OZ2UdoJlS]AIV(MI8g<]APHr-N'H*hdtoUG@9VZ?)'e7094iS;]A4Vrh;K?kLE*6#TI&C0;
TbH8';fs=3*kRe8HZqg;FYMDS$/k$h"R;64GUC<R_R2GZtgA5)\=P./J9m7he!c18M[)(_8h
YY]A'Vm0%qZ)1\?DTqVNaf,Wokd&f^ON[T_CE&,#H`5qjL-[.8<q)7#>Fk79DFML8ubQmRpo*
o03<AnE9]Ab.aL=noUR,n0\q37m!?u=e.K73(2WujZGm%EJ6i[;E6>F.1VU&)P30[!k^"%K]AZ
f#k;bt-LEr.TF&o$6fRcS.eqN2T/fH31dH9X'H`TC_LLW<d$Y*0+(-F*F\lV1Y$`Imp_tJM^
?ULQso`Ts%h`k%aDWg*?lrIPXFV"X5"u"sq0Se@clD.K+"@q*C%Jup#Ed]A%IcLHUON1Pjred
41&b,nJ<7C-H?:[N=E=.t2[=fTf&TY5ZnJM*4X"eknQ1q:V[H(O5Jf`pKfS.Qo70`toh_g$G
;c'tJn3TDPgL!I#hdY+/G'>n9n_2"KS_Z"QoKVmgM2a;#QTDd"Rb#a?L-6^!Lro-['<>?-H?
!1B7^X)_Th!PVCekC$IhDG;RYiA*EmAZ:^1LY2=G1\7L0+0_VjJFDCYGDYbHe8,\R3KY2"K5
KqIdLoEJTG&KT^8-.RaJ>R%n'_2K@\[fRRg?or#C.53kjdRrdA*NkuT3;jqF)1EduR)>Peoq
kQ[i<rGRrN1IVEj)rVmq*!V5OED`<^@h<Z%gt\cr$8YEc6Z`^5M"I-EjjT:QdTYRQeTS]A--2
7'aoFD;Lqb2O4Rm5(1HXi'EqA$r.]A):P]AW$.E-8g$k_L[/)aNX9kCi$;)B;fI3S1O'3oq12H
Uq51/e'=5(0j/VU/EOWU<-WpVe7L)LIfi^XTL7dX*Z2S"B>;+e9<F7PZ>B,e]A=54\Fqi)r1R
nFj5qRsF?WYQ)Y:Q,A#Yn5T`UmeR\c5L9!G*h7n6'UDr5<0X#o_d1mKoGo'hUjJ@>%/%4O+^
M!5]Akq*4+G&P*KkoBnDM+o@f\NO]AQ`df?*Q[QMH?f.-B[H:rre>pqBgi?(Xn:AJ=Gk'N%d$8
dn_6iG>lPHnn1*ZIE4jIMa,Dr(%@]A^$TRf7ilRaM'97/,E+sCC#?$aPHCYm_:-otASuiXnO_
=6*^7#"q:L&USX]A09ZNTa9Q4%[Y>RdR#Af4>g]AQcqe_mUoS8c-q`k9Z('X?5]AkCO`!/EI\j=
^[TRh_.'!A\o/8Jn-*&&aaEt/!_'V:2%It'k%oOjhJQ,1bJKY5qZR1ca)q.XocTa9]AUi2Ip5
/\NqW%E&$65[=T-p.Yj&qj`]AHtjp&^]AM,P<@YDiLi`5e:t1Jm$/lr>!@,b'$@>a9^-1]AJpE!
@WKE&$o4Z`j`Vr.R?]Al+_aXaAdelqh4S#jO(kY4+B\8I<=J'QZ+7`d>AJW\'Tf7Bjd#k5i>9
h>Y/u%<[PH13P,Nc+3QRHTnj+fJF=jf`(eRk$=sf$oN#'$)9_=q&&hQ$Ur69^QEsE&VaUGZu
jJH<+j-[l`Ermp)!cJ`RdP:;43\/mShPdEf"?'<FL*Wn=mL1kM_OGlI^@)4Z2Fh)I08kA%cN
&4'\?#atlRPR?<U-HL2E[VJkf,7FlK,\NZMt*!_'BQI=%87#>)!qim;;M-7+^X3]Al<k^Y\WL
*(=!27r5Sff^[3@'d<WM,_sQ(-OOQN?&jUkm'24OiT>NpSui4^'9E7P!B#UJPGZDc)ZA4h_,
P="Ab=6!'=7t,4-K4pG2;Oeiq:_>_=,AJ;f!=A1e^6+7@R^N!t1&eobUp&En:\+'kJg=oWL'
=o$i$A1gC-gJ!f28D+s0SK^gR&EqM>Z).$]A%qa<'+l,gL=[9@:-h]AqiA#`ur/C^k]A+ogg@f5
[`>9]Ab[6rPXsgjZ'5M0el0QEjS2N$lT]APVD#l0+57FVWd]AH+RBVbO^ujhsmSmQ[K"\SnDnIP
^(L(%"hoQB+e^.!onQI/<[ocmRmSH/ai7-6;cT=S8NkHo#.]A3]A-JmtNN"@`C5#&B!(`-kYPL
EF_g[SJRKB3V%R>GZi6$:8Y;rr,QfcVJ,2'EE(jk,O&$),csK*UMerN=o\RX#6F4DS0BLbX2
?qrnYYPb;VED`<e)IF[%+qK5KJQLqZH(B4'ktB>c?WQk'EC]AB&2P$orX5%[Y5kIH58+;XI.7
Cj<hc<(]AQN5:ePs%0\b"9);jT!Fboo'G;^t-<QfJ2R#S\jkYYg=&85#TKL*ANL)f,mprttD4
UJf)Wb5)#el/#L4[/l6m&%VmlVTG]Am^m8^!Pj.bZenqHjsYuMcJdcER]AnKY@,tK0g3;rqiu/
a=apA9'OEQbdkQRuNV$1g@b(j%$K^=;$k6Wf:ZHqFmUFBjqio@,/0d@(D&k()4dmsb9uN#b2
B0-q`ODVtA$Qk*U2bb2Lk[B#):0G=&@%BTQK11DKoQHY2U-.\jnE^SHt</f@$I!onqNc0T+=
590^G[X(B^RdA;HGWPO34e-GlsHr93!Eh1a/>"h`YT@I=eAQn=ZYbV1CuWHHk4:Fgb4Q(&hT
H]Ae3f\[q-nEo5UCnT6;<Z0sm4?IZ`g>2'kBGa'^FH"2raVfCV7g-:SWZ'4ql<=U9!;i%b+43
DeHCR(qjY'M9G5.*Q88gXN1,a@2T+.l)?&2`iHnE<+trG[qEC#%DXTPr&QaTPpO]AU!/$Xa0f
iA[/t>dY*FY_4e"PqkW?a.V2]AGS]AmZb(\Q%QV<g1`F#oF7(2l&2UQN4XY,S)[1SZ>n`*7,U#
q&`aT;7/PhB:B!<L!m=:n1GP"=D*@Jp3$/ad8<H7,6u`"]Ab>t"@clM'NTUUo&-Ch.R\R+eDm
oW`m1k6R4L![^VI+F"K\Oc\0H!-;9g\A.5X`uC9q!eN*R#%h5/#O6anM_J_R"arCrNNl+p.0
]AmZIXgl@WD?XCB8A63CF:F)gBJXcWLjj+Z%4$gHHc]AMr(lWt!KSbH!`P$;8u>\RuGWi,[J]A>
j$GX(<CQmjkI=h/s6$b12TY+2BR_ZQl%DHr8XGVJfpJX$l(0>KsXbqk&W%l;88ci4KpOk&pk
f#?-=R[spX&jDk4#3e+N5QS+P)cq$eBCA;Os$.q:Mb*l.qn1L$-(l*@H*ilt,rMkkN'8+us@
q&&qF%HDkfZ/.6H#3pM*FbV*GlG\.hfRG`8>.k:p'U7NjR4]A)2t5K@@Y5h-@MqWq'5+W(j8-
6YrsYC#Te(4V1s?niLsKZ!.tRUYi9cLS-,Z2!lT4pWc@"4U-W!oS_E8]AGR5Y_B-qNPMhp&d#
P&Q;`NQ/-:Q#fd$c"PqYY5`BH+K<H!WDp(2Cb#8ubYU,Wc-`$l'Tgqd]AG,Te.s5MR%U]ApHJC
)pkcutt`VSDY2L8=&r672WdZ,GbucoPbA>Kkj_6BEJ!<q'#G/Jj+rLVg$NB:@5;4(&!5E2K:
q!7Wtr[E'Qt+GoFq\p$mB)8m,.M\>k-F>2!Ubk#lTJ!oIr(PUmRmu,P\m9C&J>#a)/`M9'dm
Q32M*6jd.S^.*J+4iFsMe=iC]AU_HK\:47LPqY=Z0Lf3iqXcX[CsSL*LPL9!RG^*O#7)(@Q:i
HNF-jr"qs`=X$^Jf;rBt5B24oTBK8`(s+]A--MS"K^!RVVYFif53:dESTZ#1M"*96'<Joq;9%
A>bDcMaTIBPLaL!qVkmYnp,[hn@TCjK*\aTqA*[dqg*J20@?a!Aa1Oig=F(bCTOs*p5IEQj8
N0F;qQ[rabQbBQ/<p3(>-(SNrC""TbJ2+'2h7@b``:(360ejFB\%?hS/lV415B,m@'BDZ7/.
8i&9DTDmha4+HUd7>DiAgBKA%q^tqeH(?S71h-^*$bE>7[XO#[jh>>GOSH]AgI!nXe0"K[Is3
K;t5N0s>C!S4J=,f]AGPh5c=gVV+.,b.J8Ijq0F$1Aau@Zn1O#pU=KD>:))c8lJcJ,6t7Gk<J
'E@D,L8;NBkD<=r.$f'NBSs#q2*Z:r/3VQ-+@PM$nYd$9`iX]A(hP9?\I6YbVE?6hn'&@Ukk_
R"(ZL_bBRM"$(3crqh8J?Y;#a'6q74!h@_pJ[c!q"fBQ-+9[TthW+3@p;WK1rA+Sm=PT7n-m
4-%e3fXeVRcN9ErNM;?F>j3LL9kM3D/lh?LUa=J'X^L`J$uXoSLA2C[")OHmoKdY0TUk\nbd
4;Z)C=ijsR0^W(_Gs.Pa\<OP#,ld@]ADb)#(n/R>g$LR*agerNs,eJTs@)rE4^0!qc&f;'b<[
Db:%Hg1OMSYafKepko1c@T5'CX(X90&<-OK9sEti+;C5GT".&?3W'8Qbgl'AahI")8$Aa#6-
mk^JI9GS,R-"X[LG!DS*?ZZKRp(eIV\F]ADpXMDMru_/IRo!bJIiLZLIm8iVHtSabT]A5Xb<O[
UPHMmiVkfbrI4h~
]]></IM>
<ReportFitAttr fitStateInPC="2" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="0" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="417" height="44"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="247" y="5" width="417" height="44"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="chart1"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="chart1" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ChartEditor">
<WidgetName name="chart1"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__C98B628C9FADB557B41820A512057ACB">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNTh?smA_iEubF,kJ>a!K*4i\i>FDb^"P`UT[@aKNk*GPNj?(F'
%3KL9`fLg^8UkQdSb_QE`tPZ5I_^oX$7,Gjjjd#CE&@cN!W.md0*T(']AKq'o1Ink'_Jq]At!4
>JaTjIGJ??>p>o!X'*H.39/!IHoWYpbVl0:eBa%>\CoP$I9Y:cB$)Y=,pSBEc]A.WR.[)[)&)
&TfMlmht3FlAe*0-KGnIcUr&`C_[Z$k*Ut%a5=i*<JK]A1C/T>.QB![.WOE$@:3d,BE\0"5]AJ
J,Y*70#T6<EIE;d8bmD':3@CGok\'>Qel$GNph)q]A^<:QpH;8o;f7hq(7*`Y>&GZ6Ct'S!L%
d.^jqg!N#Uje]ArU'#9OKL\U/hM>eXb#8Doe5Nd*)kqX"L%V/$2]A/&rKm'f_2IC_q'+5!Cr?6
&>B11cI"p2e]A.[K(Y?AX<(@rM'fp0<Y8$*+VOUSqfRoU#I$3\IFZO-^NYZ%cf?h]A)&t=F%U*
I!!~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<LayoutAttr selectedIndex="0"/>
<ChangeAttr enable="false" changeType="button" timeInterval="5" showArrow="true">
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="PingFangSC-Regular" style="0" size="96">
<foreground>
<FineColor color="-1" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<buttonColor>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</buttonColor>
<carouselColor>
<FineColor color="-8421505" hor="-1" ver="-1"/>
</carouselColor>
</ChangeAttr>
<Chart name="默认" chartClass="com.fr.plugin.chart.vanchart.VanChart">
<Chart class="com.fr.plugin.chart.vanchart.VanChart">
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<ChartAttr isJSDraw="true" isStyleGlobal="false"/>
<Title4VanChart>
<Title>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-6908266" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="微软雅黑" style="0" size="128">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<TitleVisible value="false" position="0"/>
</Title>
<Attr4VanChart useHtml="false" floating="false" x="0.0" y="0.0" limitSize="false" maxHeight="15.0"/>
</Title4VanChart>
<SwitchTitle>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<O>
<![CDATA[新建图表标题]]></O>
</SwitchTitle>
<Plot class="com.fr.plugin.chart.PiePlot4VanChart">
<VanChartPlotVersion version="20170715"/>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1118482" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isNullValueBreak="true" autoRefreshPerSecond="3" seriesDragEnable="false" plotStyle="0" combinedSize="50.0"/>
<newHotTooltipStyle>
<AttrContents>
<Attr showLine="false" position="1" isWhiteBackground="true" isShowMutiSeries="false" seriesLabel="${VALUE}"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##]]></Format>
<PercentFormat>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#0.##%]]></Format>
</PercentFormat>
</AttrContents>
</newHotTooltipStyle>
<ConditionCollection>
<DefaultAttr class="com.fr.chart.chartglyph.ConditionAttr">
<ConditionAttr name="">
<AttrList>
<Attr class="com.fr.chart.base.AttrBorder">
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-1" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrTooltip">
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: left;&quot;&gt;&lt;img data-id=&quot;${SERIES}&quot;/&gt;&lt;br&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${SERIES}${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#,##0.00]]></Format>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="true" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.5"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</Attr>
<Attr class="com.fr.plugin.chart.base.AttrLabel">
<AttrLabel>
<labelAttr enable="true"/>
<labelDetail class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="true" isHorizontal="true" autoAdjust="false" position="6" align="9" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="true">
<FRFont name="宋体" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${VALUE}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${VALUE}"/>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="false"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="true"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="function(){ return this.seriesName+this.value+this.percentage;}" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</labelDetail>
<gaugeValueLabel class="com.fr.plugin.chart.base.AttrLabelDetail">
<AttrBorderWithShape>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="2"/>
<newColor autoColor="true" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
<shapeAttr isAutoColor="true" shapeType="RectangularMarker"/>
</AttrBorderWithShape>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
<Attr showLine="false" isHorizontal="true" autoAdjust="false" position="3" align="9" isCustom="true"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="80">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<PieCategoryLabelContent>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="Verdana" style="0" size="80">
<foreground>
<FineColor color="-13421773" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="&lt;p style=&quot;text-align: center;&quot;&gt;&lt;img data-id=&quot;${CATEGORY}&quot;/&gt;&lt;br&gt;&lt;/p&gt;" isAuto="true" initParamsContent="${CATEGORY}"/>
</AttrTooltipRichText>
</richText>
<richTextSummaryValue class="com.fr.plugin.chart.base.format.AttrTooltipSummaryValueFormat">
<AttrTooltipSummaryValueFormat>
<Attr enable="false"/>
</AttrTooltipSummaryValueFormat>
</richTextSummaryValue>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="true" isRichText="false" richTextAlign="center" showAllSeries="false"/>
<summaryValue class="com.fr.plugin.chart.base.format.AttrTooltipSummaryValueFormat">
<AttrTooltipSummaryValueFormat>
<Attr enable="false"/>
</AttrTooltipSummaryValueFormat>
</summaryValue>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</category>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
</PieCategoryLabelContent>
</gaugeValueLabel>
</AttrLabel>
</Attr>
</AttrList>
</ConditionAttr>
</DefaultAttr>
<ConditionAttrList>
<List index="0">
<ConditionAttr name="条件属性1">
<AttrList>
<Attr class="com.fr.plugin.chart.base.AttrEffect">
<AttrEffect>
<attr enabled="true" period="2.0"/>
</AttrEffect>
</Attr>
</AttrList>
<Condition class="com.fr.chart.chartattr.ChartCommonCondition">
<CNUMBER>
<![CDATA[4]]></CNUMBER>
<CNAME>
<![CDATA[VALUE]]></CNAME>
<Compare op="2">
<O>
<![CDATA[0]]></O>
</Compare>
</Condition>
</ConditionAttr>
</List>
</ConditionAttrList>
</ConditionCollection>
<Legend4VanChart>
<Legend>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="0" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-3355444" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr position="4" visible="false" themed="false"/>
<FRFont name="微软雅黑" style="0" size="88">
<foreground>
<FineColor color="-10066330" hor="-1" ver="-1"/>
</foreground>
</FRFont>
</Legend>
<Attr4VanChart floating="false" x="0.0" y="0.0" layout="aligned" customSize="true" maxHeight="100.0" isHighlight="true"/>
</Legend4VanChart>
<DataSheet>
<GI>
<AttrBackground>
<Background name="NullBackground"/>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="0"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-16777216" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="1.0"/>
</AttrAlpha>
</GI>
<Attr isVisible="false" themed="false"/>
<FRFont name="SimSun" style="0" size="72"/>
</DataSheet>
<DataProcessor class="com.fr.base.chart.chartdata.model.NormalDataModel"/>
<newPlotFillStyle>
<AttrFillStyle>
<AFStyle colorStyle="1"/>
<FillStyleName fillStyleName="新特性"/>
<isCustomFillStyle isCustomFillStyle="true"/>
<PredefinedStyle themed="true"/>
<ColorList>
<OColor>
<colvalue>
<FineColor color="-10243346" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8988015" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-472193" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-486008" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8595761" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-7236949" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-8873759" hor="-1" ver="-1"/>
</colvalue>
</OColor>
<OColor>
<colvalue>
<FineColor color="-1071514" hor="-1" ver="-1"/>
</colvalue>
</OColor>
</ColorList>
</AttrFillStyle>
</newPlotFillStyle>
<VanChartPlotAttr isAxisRotation="false" categoryNum="1"/>
<GradientStyle>
<Attr gradientType="normal">
<startColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</startColor>
<endColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</endColor>
</Attr>
</GradientStyle>
<PieAttr4VanChart roseType="normal" startAngle="0.0" endAngle="360.0" innerRadius="65.0" supportRotation="false"/>
<VanChartRadius radiusType="fixed" radius="50"/>
</Plot>
<ChartDefinition>
<OneValueCDDefinition seriesName="分类" valueName="总金额" function="com.fr.plugin.chart.base.FirstFunction">
<Top topCate="-1" topValue="-1" isDiscardOtherCate="false" isDiscardOtherSeries="false" isDiscardNullCate="false" isDiscardNullSeries="false"/>
<TableData class="com.fr.data.impl.NameTableData">
<Name>
<![CDATA[月度各品类销售额]]></Name>
</TableData>
<CategoryName value="无"/>
</OneValueCDDefinition>
</ChartDefinition>
</Chart>
<UUID uuid="c740cb08-6d5c-43a2-bc69-4090a58ee3c6"/>
<tools hidden="true" sort="false" export="false" fullScreen="false"/>
<VanChartZoom>
<zoomAttr zoomVisible="false" zoomGesture="true" zoomResize="true" zoomType="xy" controlType="zoom" categoryNum="8" scaling="0.3"/>
<from>
<![CDATA[]]></from>
<to>
<![CDATA[]]></to>
</VanChartZoom>
<refreshMoreLabel>
<attr moreLabel="false" autoTooltip="true"/>
<AttrTooltip>
<Attr enable="true" duration="4" followMouse="false" showMutiSeries="false" isCustom="false"/>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="SimSun" style="0" size="72"/>
</Attr>
</TextAttr>
<AttrToolTipContent>
<TextAttr>
<Attr alignText="0" themed="false">
<FRFont name="SimSun" style="0" size="72"/>
</Attr>
</TextAttr>
<richText class="com.fr.plugin.chart.base.AttrTooltipRichText">
<AttrTooltipRichText>
<Attr content="" isAuto="true" initParamsContent=""/>
<params>
<![CDATA[{}]]></params>
</AttrTooltipRichText>
</richText>
<richTextValue class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</richTextValue>
<richTextPercent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</richTextPercent>
<richTextCategory class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="false"/>
</AttrToolTipCategoryFormat>
</richTextCategory>
<richTextSeries class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="false"/>
</AttrTooltipSeriesFormat>
</richTextSeries>
<richTextChangedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</richTextChangedPercent>
<richTextChangedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="false"/>
</AttrTooltipChangedValueFormat>
</richTextChangedValue>
<TableFieldCollection/>
<Attr isCommon="true" isCustom="false" isRichText="false" richTextAlign="left" showAllSeries="false"/>
<value class="com.fr.plugin.chart.base.format.AttrTooltipValueFormat">
<AttrTooltipValueFormat>
<Attr enable="true"/>
</AttrTooltipValueFormat>
</value>
<percent class="com.fr.plugin.chart.base.format.AttrTooltipPercentFormat">
<AttrTooltipPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipPercentFormat>
</percent>
<category class="com.fr.plugin.chart.base.format.AttrTooltipCategoryFormat">
<AttrToolTipCategoryFormat>
<Attr enable="true"/>
</AttrToolTipCategoryFormat>
</category>
<series class="com.fr.plugin.chart.base.format.AttrTooltipSeriesFormat">
<AttrTooltipSeriesFormat>
<Attr enable="true"/>
</AttrTooltipSeriesFormat>
</series>
<changedPercent class="com.fr.plugin.chart.base.format.AttrTooltipChangedPercentFormat">
<AttrTooltipChangedPercentFormat>
<Attr enable="false"/>
<Format class="com.fr.base.CoreDecimalFormat" roundingMode="6">
<![CDATA[#.##%]]></Format>
</AttrTooltipChangedPercentFormat>
</changedPercent>
<changedValue class="com.fr.plugin.chart.base.format.AttrTooltipChangedValueFormat">
<AttrTooltipChangedValueFormat>
<Attr enable="true"/>
</AttrTooltipChangedValueFormat>
</changedValue>
<HtmlLabel customText="" useHtml="false" isCustomWidth="false" isCustomHeight="false" width="50" height="50"/>
</AttrToolTipContent>
<GI>
<AttrBackground>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
<Attr gradientType="normal" shadow="false" autoBackground="false" themed="false">
<gradientStartColor>
<FineColor color="-12146441" hor="-1" ver="-1"/>
</gradientStartColor>
<gradientEndColor>
<FineColor color="-9378161" hor="-1" ver="-1"/>
</gradientEndColor>
</Attr>
</AttrBackground>
<AttrBorder>
<Attr lineStyle="1" isRoundBorder="false" roundRadius="4"/>
<newColor autoColor="false" themed="false">
<borderColor>
<FineColor color="-15395563" hor="-1" ver="-1"/>
</borderColor>
</newColor>
</AttrBorder>
<AttrAlpha>
<Attr alpha="0.8"/>
</AttrAlpha>
</GI>
</AttrTooltip>
</refreshMoreLabel>
<ThemeAttr>
<Attr darkTheme="false"/>
</ThemeAttr>
</Chart>
<ChartMobileAttrProvider zoomOut="0" zoomIn="2" allowFullScreen="true" functionalWhenUnactivated="false"/>
<MobileChartCollapsedStyle class="com.fr.form.ui.mobile.MobileChartCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
</MobileChartCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="222" height="151"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="10" y="382" width="222" height="151"/>
</Widget>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.container.WTitleLayout">
<WidgetName name="report4_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="-1.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="report4" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="0" left="0" bottom="0" right="0"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="SimSun" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Alpha alpha="1.0"/>
</Border>
<LCAttr vgap="0" hgap="0" compInterval="0"/>
<Widget class="com.fr.form.ui.container.WAbsoluteLayout$BoundsWidget">
<InnerWidget class="com.fr.form.ui.ElementCaseEditor">
<WidgetName name="report4_c_c_c_c_c"/>
<WidgetAttr aspectRatioLocked="false" aspectRatioBackup="0.0" description="">
<MobileBookMark useBookMark="false" bookMarkName="" frozen="false"/>
<PrivilegeControl/>
</WidgetAttr>
<FollowingTheme borderStyle="false"/>
<Margin top="1" left="1" bottom="1" right="1"/>
<Border>
<border style="0" borderRadius="0" type="0" borderStyle="0">
<color>
<FineColor color="-723724" hor="-1" ver="-1"/>
</color>
</border>
<WidgetTitle>
<O>
<![CDATA[新建标题]]></O>
<FRFont name="宋体" style="0" size="72"/>
<Position pos="0"/>
</WidgetTitle>
<Background name="ImageBackground" layout="2">
<FineImage fm="png" imageId="__ImageCache__54747B55D03CBA03B526498E03A03464">
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNS-%`Gt=fRP082QODE0Slk%FE%_gR.L%J`_9u7&_B:u;caoN(\
-W&+$LXt,W.<hdBSo"Y`<_>q<$T;s)7=b3A]AI,Z?K=A2XWYBs5s@aBh`'Zqm1S"0:Q2<PlnS
K'`.fIgqM`#'*CThq'-1gBiE*j^u-om!Z7X=r\D\+$kq.f(`=/c#Qk0tiCRZ;OSj4=&4fibW
-kIr?/Jr%hf%5"MDd!lf?`3!qs0T\@(H(I(d"aF<;EK`;<=Rq8!T,b+&tM)HrTp?nknMDb"%
_X.N_YSWdIeAW:IctI#jajr;6KVVj[>5)&Ntpld&c$NqK"TdeuFu<Yk/2OF()LLQ@#FJ<\ft
HZ.&CCRZDI!&Z%k5.WJQUTunPl592]AcPnJc:MU$CPeki!cXiYG65'>~
]]></IM>
</FineImage>
</Background>
<Alpha alpha="1.0"/>
</Border>
<FormElementCase>
<ReportPageAttr>
<HR/>
<FR/>
<HC/>
<FC/>
</ReportPageAttr>
<ColumnPrivilegeControl/>
<RowPrivilegeControl/>
<RowHeight defaultValue="723900">
<![CDATA[723900,723900,723900,723900,723900,723900,723900,723900,723900,723900,723900]]></RowHeight>
<ColumnWidth defaultValue="2743200">
<![CDATA[2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200,2743200]]></ColumnWidth>
<CellElementList>
<C c="0" r="0" s="0">
<PrivilegeControl/>
<Expand>
<cellSortAttr/>
</Expand>
</C>
</CellElementList>
<ReportAttrSet>
<ReportSettings headerHeight="0" footerHeight="0">
<PaperSetting/>
<FollowingTheme background="true"/>
<Background name="ColorBackground">
<color>
<FineColor color="-1" hor="-1" ver="-1"/>
</color>
</Background>
</ReportSettings>
</ReportAttrSet>
</FormElementCase>
<StyleList>
<Style style_name="默认" full="true" border_source="-1" imageLayout="1">
<FRFont name="simhei" style="0" size="72"/>
<Background name="NullBackground"/>
<Border/>
</Style>
</StyleList>
<heightRestrict heightrestrict="false"/>
<heightPercent heightpercent="0.75"/>
<IM>
<![CDATA[lO<9(kN.ld@UNU%p%320@UNSDARJmUj^81JoJ+[XARLVpm-3LH;DI@ZNJ!YC%K\2AQN*:FR@
,;KnBH4$JT]A5Pj>ZP2Z^H;Lr;GM9qERa`$',gFm7ioP0lI>snpb-P1)b6:5:$_-TsaVP:0,]A
M'*=$i;=4+]A#;I'E`4L8GBE_Bh-4m9s#Zfm23=/)6GYMTId6W[i5h#o[<No>!1cReV-)4X6[
>nuBeN0^Q<9pL6;6?Ts8%"@l*S!3NF]A@\*ekrQE>">u\C)thcWg1k5CUPV"K=O_Vp4$lF4M]A
&Mi<e)*TF*Do.R\D]A&D2q=acS(kqS_BT`r8a!`?7HB=$N$o:'jVp~
]]></IM>
<ReportFitAttr fitStateInPC="3" fitFont="false" minFontSize="0"/>
<ElementCaseMobileAttrProvider horizontal="1" vertical="1" zoom="true" refresh="false" isUseHTML="false" isMobileCanvasSize="false" appearRefresh="false" allowFullScreen="false" allowDoubleClickOrZoom="true" functionalWhenUnactivated="false"/>
<MobileFormCollapsedStyle class="com.fr.form.ui.mobile.MobileFormCollapsedStyle">
<collapseButton showButton="true" foldedHint="" unfoldedHint="" defaultState="0">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
</collapseButton>
<collapsedWork value="false"/>
<lineAttr number="1"/>
</MobileFormCollapsedStyle>
</InnerWidget>
<BoundsAttr x="0" y="0" width="271" height="228"/>
</Widget>
<ShowBookmarks showBookmarks="false"/>
</InnerWidget>
<BoundsAttr x="681" y="67" width="271" height="228"/>
</Widget>
<ShowBookmarks showBookmarks="true"/>
<Sorted sorted="false"/>
<MobileWidgetList>
<Widget widgetName="report100"/>
<Widget widgetName="report2"/>
<Widget widgetName="report6_c"/>
<Widget widgetName="report6_c_c"/>
<Widget widgetName="report3"/>
<Widget widgetName="report3_c_c_c"/>
<Widget widgetName="chart000"/>
<Widget widgetName="absolute10_c"/>
<Widget widgetName="report4_c_c_c_c_c"/>
<Widget widgetName="chart0000"/>
<Widget widgetName="report3_c_c_c_c_c"/>
<Widget widgetName="chart01"/>
<Widget widgetName="chart0000_c"/>
<Widget widgetName="report3_c_c_c_c"/>
<Widget widgetName="report3_c"/>
<Widget widgetName="chart0"/>
<Widget widgetName="chart1"/>
</MobileWidgetList>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetScalingAttr compState="0"/>
<AppRelayout appRelayout="true"/>
</InnerWidget>
<BoundsAttr x="0" y="0" width="960" height="540"/>
</Widget>
<ShowBookmarks showBookmarks="true"/>
<Sorted sorted="true"/>
<MobileWidgetList/>
<FrozenWidgets/>
<MobileBookMarkStyle class="com.fr.form.ui.mobile.impl.DefaultMobileBookMarkStyle"/>
<WidgetZoomAttr compState="0" scaleAttr="2"/>
<AppRelayout appRelayout="true"/>
<Size width="960" height="540"/>
<BodyLayoutType type="1"/>
</Center>
</Layout>
<DesignerVersion DesignerVersion="LAA"/>
<PreviewType PreviewType="6"/>
<TemplateThemeAttrMark class="com.fr.base.iofile.attr.TemplateThemeAttrMark">
<TemplateThemeAttrMark name="兼容主题" dark="false"/>
</TemplateThemeAttrMark>
<WatermarkAttr class="com.fr.base.iofile.attr.WatermarkAttr">
<WatermarkAttr fontSize="20" horizontalGap="200" verticalGap="100" valid="false">
<color>
<FineColor color="-6710887" hor="-1" ver="-1"/>
</color>
<Text>
<![CDATA[]]></Text>
</WatermarkAttr>
</WatermarkAttr>
<StrategyConfigsAttr class="com.fr.esd.core.strategy.persistence.StrategyConfigsAttr">
<StrategyConfigs>
<StrategyConfig dsName="同比分析" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="部门销售额以及达成率" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="冰粽月维度总销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销售贡献榜的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度渠道冰粽毛利率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="线下排行" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销量贡献榜" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度成本分析" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="冰粽年累计销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="京东销售额以及达成率的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="五大季节品" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="各季节品销量" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月维度业务员目标达成率" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="年累计销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="热门产品TOP10" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="时间维度销售额和成本" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="ds2月度人员目标" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="BI2024总销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="日维度销售贡献榜" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月度区域目标" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="月度各品类销售额" enabled="false" useGlobal="true" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
<StrategyConfig dsName="冰粽日维度销售额的副本" enabled="false" useGlobal="false" shouldMonitor="true" shouldEvolve="false" scheduleBySchema="false" timeToLive="1500000" timeToIdle="86400000" updateInterval="1500000" terminalTime="" updateSchema="0 0 8 * * ? *" activeInitiation="false"/>
</StrategyConfigs>
</StrategyConfigsAttr>
<NewFormMarkAttr class="com.fr.form.fit.NewFormMarkAttr">
<NewFormMarkAttr type="1" tabPreload="true" fontScaleFrontAdjust="true" supportColRowAutoAdjust="true" supportExportTransparency="false"/>
</NewFormMarkAttr>
<TemplateIdAttMark class="com.fr.base.iofile.attr.TemplateIdAttrMark">
<TemplateIdAttMark TemplateId="31dc8673-ef37-4837-8e01-4fc1dbdb3446"/>
</TemplateIdAttMark>
</Form>
