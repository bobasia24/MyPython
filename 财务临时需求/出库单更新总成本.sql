

update
rpa.ods_01财务_rpa_金蝶云星空_销售出库单 a
left join  (
select
material_code,
sum(amount_excluding_tax)/sum(pricing_quantity)  单价
from
rpa.ods_01财务_金蝶_应付单列表_月维度
where business_date like '2023-11%' and payment_organization = '深圳榴芒'
group by material_code )b
on  a.material_code =b.material_code
set a.total_cost = a.issued_quantity*b.单价
where qry_date ='2023-11'
and shipment_organization = '深圳榴芒'

-- 55436337.60976793

-- 55436337.60976793
select sum(total_cost), count(1) from rpa.ods_01财务_rpa_金蝶云星空_销售出库单  where `date` like '2023-10%'
and shipment_organization = '深圳榴芒'



select sum(total_cost), count(1)  from  rpa.ods_01财务_rpa_金蝶云星空_销售出库单_test  where `date` like '2023-10%'
and shipment_organization = '深圳榴芒'
and material_code= 'pddllqc01'



-- 校验应付单和出库单每个料的合计总数

-- 176188.000000000
select * from
(select material_code,

sum(pricing_quantity) 总量
from
rpa.ods_01财务_金蝶_应付单列表_月维度
where business_date like '2023-10%' and payment_organization = '深圳榴芒'
group by material_code )a

join
-- 176188.0
(select material_code,
sum(issued_quantity) 总量

from rpa.ods_01财务_rpa_金蝶云星空_销售出库单_test   where `date` like '2023-10%'
and shipment_organization = '深圳榴芒'
group by material_code )b
on a.material_code=b.material_code
where a.总量 =b.总量


-- 查出每个料按公式计算后总成本不一致的料
select * from
(select 'a123' material_code,
 sum(amount_excluding_tax) 不含税合计
from
rpa.ods_01财务_金蝶_应付单列表_月维度
where business_date like '2023-10%' and payment_organization = '深圳榴芒'
 group by material_code
)a


left join

(select  sum(total_cost) 不含税合计, 'a123' material_code  from  rpa.ods_01财务_rpa_金蝶云星空_销售出库单_test  where `date` like '2023-10%'
and shipment_organization = '深圳榴芒'
 group by material_code
)b
on a.material_code=b.material_code
where a.不含税合计!=b.不含税合计
