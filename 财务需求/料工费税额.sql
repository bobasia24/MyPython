
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

