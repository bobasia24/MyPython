-- 人工计算料工费
select
    序号,
    ad.产品编码,
    ad.产品名称,
    实发数量,
    总成本含税,
    a.料 * 实发数量 料,
    a.工 * 实发数量 工,
    a.费 * 实发数量 费,
    a.含税成本 * 实发数量 含税成本,
    a.不含税成本 * 实发数量 不含税成本 -- 修改表名
from
    profit.ods_2402东莞总成本单品 ad
    left join -- 检查代码字段与表中的字段是否一致
    (
        select
            '2024-02' 年月,
            产品编码 产品编码_1,
            产品名称,
            sum(料金额) / sum(实发数量) 料,
            sum(工金额) / sum(实发数量) 工,
            sum(费金额) / sum(实发数量) 费,
            sum(含税成本) / sum(实发数量) 含税成本,
            sum(不含税成本) / sum(实发数量) 不含税成本,
            '' 成本单价
        from
            -- 修改表名
            profit.ods_2402东莞总成本
        group by
            产品编码
    ) a on a.产品编码_1 = ad.产品编码