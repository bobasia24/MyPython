
select c.序号,c.运输单号,c.总成本含税,a.总总成本含税,c.总成本含税/a.总总成本含税 as 比例,
(c.总成本含税/a.总总成本含税)*b.含税金额 含税运费,(c.总成本含税/a.总总成本含税)*b.不含税金额 不含税运费,(c.总成本含税/a.总总成本含税)*b.税额 税额,c.`客户名称-更改`
from
profit.手动导入11月临时表 c
left join
-- 获取合计成本
(select 序号,运输单号,sum(总成本含税)总总成本含税  from
profit.手动导入11月临时表
group by 运输单号 )a
on a.运输单号=c.运输单号
left join
-- 关联运费
profit.手动导入11月运费 b
on  a.运输单号 = b.单号
order by c.序号






