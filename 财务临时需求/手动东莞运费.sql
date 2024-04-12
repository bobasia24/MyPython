
select sum(总成本含税),sum(总总成本含税)  from (
select c.序号,c.运输单号,c.总成本含税,a.总总成本含税,c.总成本含税/a.总总成本含税 as 比例,
(c.总成本含税/a.总总成本含税)*b.含税金额 含税运费,(c.总成本含税/a.总总成本含税)*b.不含税金额 不含税运费,(c.总成本含税/a.总总成本含税)*b.税额 税额
from
profit.ods_2402运费临时表 c
left join
-- 获取合计成本
(select 序号,运输单号,sum(总成本含税)总总成本含税  from
profit.ods_2402运费临时表
group by 运输单号 )a
on a.运输单号=c.运输单号
left join
-- 关联运费
(select 单号,sum(含税金额) 含税金额,
税率,
sum(不含税金额) 不含税金额,
sum(税额)税额 from
profit.ods_2402运费 group by 单号) b
on  a.运输单号 = b.单号
order by c.序号)dd

select c.序号,c.运输单号,c.总成本含税,a.总总成本含税,c.总成本含税/a.总总成本含税 as 比例,
(c.总成本含税/a.总总成本含税)*b.含税金额 含税运费,
(c.总成本含税/a.总总成本含税)*b.含税金额 /1.06 不含税运费,
(c.总成本含税/a.总总成本含税)*b.含税金额 -  (c.总成本含税/a.总总成本含税)*b.含税金额 /1.06  税额
from
profit.人工导入202402单品 c
left join
-- 获取合计成本
(select 序号,运输单号,sum(总成本含税)总总成本含税  from
profit.人工导入202402单品
group by 运输单号 )a
on a.运输单号=c.运输单号
left join
-- 关联运费
(select 单号,sum(含税金额) 含税金额 from
profit.人工导入202402运费汇总 group by 单号) b
on  a.运输单号 = b.单号
order by c.序号




------ 按成本均摊运费代码

select a.序号,a.运输单号,a.匹配顺丰单号,a.总成本含税,b.运费含税,b.运费含税/1.06 运费不含税,b.运费含税 - (b.运费含税/1.06) 税额
from profit.手动导入_202401_东莞运费 a
left join
(
-- 比例分母以及待分摊总额需修改
select 序号,(总成本含税/8943912.919991484)* 1449371.59 运费含税 from
profit.手动导入_202401_东莞运费
where 匹配顺丰单号 is not null )b
on a.序号 = b.序号
order by a.序号

