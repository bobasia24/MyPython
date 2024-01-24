
select 年月,物料编码_1,物料名称,料,工,费,含税成本,不含税成本,成本单价,税额  from (
select * from (
select '2023-08' 年月,物料编码 物料编码_1,物料名称,sum(料)/sum(实发数量) 料,sum(工)/sum(实发数量) 工,sum(费)/sum(实发数量) 费,sum(总成本)/sum(实发数量) 含税成本,sum(含税成本)/sum(实发数量) 不含税成本,''成本单价 from
profit.ods_东莞产品毛利表 where  客户 = '深圳市榴芒一刻食品有限公司'
group by  物料编码 ) a
left join 
(select 物料编码,税额 from profit.ods_物料税额) b
on a.物料编码_1= b.物料编码
union  
select * from (
select '2023-08' 年月,物料编码 物料编码_1,物料名称,sum(料)/sum(实发数量) 料,sum(工)/sum(实发数量) 工,sum(费)/sum(实发数量) 费,sum(总成本)/sum(实发数量) 含税成本,sum(含税成本)/sum(实发数量) 不含税成本,''成品单价 from
profit.ods_东莞产品毛利表 where  客户 = '深圳市榴芒一刻食品有限公司'
group by  物料编码 ) a
right join 
(select 物料编码,税额 from profit.ods_物料税额) b
on a.物料编码_1= b.物料编码)c



select 年月,物料编码_1,物料名称,料,工,费,含税成本,不含税成本,成本单价,税额  from (
select * from (
select '2023-09' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(总成本)/sum(实发数量) 含税成本,sum(含税成本)/sum(实发数量) 不含税成本,''成本单价 from
profit.`2023-09收入成本表` where  客户 = '深圳市榴芒一刻食品有限公司'
group by  物料编码 ) a
left join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.手动导入_ods_10月税额
group by 物料编码) b
on a.物料编码_1= b.物料编码
union
select * from (
select '2023-09' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(总成本)/sum(实发数量) 含税成本,sum(含税成本)/sum(实发数量) 不含税成本,''成品单价 from
profit.`2023-09收入成本表` where  客户 = '深圳市榴芒一刻食品有限公司'
group by  物料编码 ) a
right join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.手动导入_ods_10月税额
group by 物料编码) b
on a.物料编码_1= b.物料编码)c



select 年月,物料编码_1,物料名称,料,工,费,含税成本,不含税成本,成本单价,税额  from (
select * from (
select '2023-10' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(含税成本)/sum(实发数量) 含税成本,sum(不含税成本)/sum(实发数量) 不含税成本,''成本单价 from
profit.人工导入10月料工费
group by  物料编码 ) a
left join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.手动导入_ods_10月税额
group by 物料编码) b
on a.物料编码_1= b.物料编码
union
select * from (
select '2023-10' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(含税成本)/sum(实发数量) 含税成本,sum(不含税成本)/sum(实发数量) 不含税成本,''成品单价 from
profit.人工导入10月料工费
group by  物料编码 ) a
right join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.手动导入_ods_10月税额
group by 物料编码) b
on a.物料编码_1= b.物料编码)c


select 年月,物料编码_1,物料名称,料,工,费,含税成本,不含税成本,成本单价,税额  from (
select * from (
select '2023-11' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(含税成本)/sum(实发数量) 含税成本,sum(不含税成本)/sum(实发数量) 不含税成本,''成本单价 from
profit.手动导入11月料工费
group by  物料编码 ) a
left join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.人工导入11月组织结算
group by 物料编码) b
on a.物料编码_1= b.物料编码
union
select * from (
select '2023-11' 年月,物料编码 物料编码_1,物料名称,sum(料金额)/sum(实发数量) 料,sum(工金额)/sum(实发数量) 工,sum(费金额)/sum(实发数量) 费,sum(含税成本)/sum(实发数量) 含税成本,sum(不含税成本)/sum(实发数量) 不含税成本,''成品单价 from
profit.手动导入11月料工费
group by  物料编码 ) a
right join
(select 物料编码,sum(税额)/sum(计价数量)  税额 from
profit.人工导入11月组织结算
group by 物料编码) b
on a.物料编码_1= b.物料编码)c





