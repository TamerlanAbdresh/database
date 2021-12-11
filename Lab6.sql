/* 1. Write a SQL query using Joins: */

-- a. combine each row of dealer table with each row of client table
select * from dealer
inner join client c on dealer.id = c.dealer_id;

-- b. find all dealers along with client name, city, grade, sell number, date, and amount
select ds.id, ds.name, location, charge, c.name as client_name, city, priority as grade, sell_number, date, amount from (select d.id, name, location, charge, s.id as sell_number, date, amount, client_id
from dealer as d
left join sell as s on d.id = s.dealer_id) as ds
left join client as c on c.id = ds.client_id;

-- c. find the dealer and client who belongs to same city
select * from dealer as d
inner join client as c on d.id = c.dealer_id
where d.location = c.city;

/* d. find sell id, amount, client name, city those sells
   where sell amount exists between 100 and 500 */
select s.id as sell_id, amount, name as client_name, city from sell as s
left join client as c on s.client_id = c.id
where amount >= 100 and amount <= 500;

/* e. find dealers who works either for one or more client
   or not yet join under any of the clients */
select * from dealer
full outer join client c on dealer.id = c.dealer_id;

/* f. find the dealers and the clients he service,
   return client name, city, dealer name, commission. */
select c.name as client_name, city, d.name as dealer_name, charge as commission from dealer as d
inner join client as c on d.id = c.dealer_id;

/* g. find client name, client city, dealer, commission
   those dealers who received a commission from the sell more than 12% */
select c.name as client_name, city as client_city, d.name as dealer, charge as commission from dealer as d
inner join client as c on d.id = c.dealer_id
where charge > 0.12;

/* h. make a report with client name, city, sell id, sell date, sell amount, dealer name
   and commission to find that either any of the existing clients haven’t made
   a purchase(sell) or made one or more purchase(sell) by their dealer or by own. */
select client_name, city, sell_id, sell_date, sell_amount, name as dealer_name, charge as commission
from (
    select name as client_name, city, s.id as sell_id, date as sell_date,
           amount as sell_amount, c.dealer_id from client as c
           full outer join sell as s on c.id = s.client_id
    ) as cs
full outer join dealer as d on cs.dealer_id = d.id;


/* i. find dealers who either work for one or more clients.
   The client may have made, either one or more purchases,
   or purchase amount above 2000 and must have a grade,
   or he may not have made any purchase to the associated dealer.
   Print client name, client grade, dealer name, sell id, sell amount
*/
select c.name as client_name, c.priority as client_grade, d.name as dealer_name,
       s.id as sell_id, s.amount as sell_amount from dealer as d
left join client c on d.id = c.dealer_id
left join sell s on c.id = s.client_id
where s.amount > 2000 and c.priority is not null;

/* 2. Create following views: */

/* a. count the number of unique clients, compute average
   and total purchase amount of client orders by each date. */
drop view IF EXISTS charge_earned;

create or replace view client_view as
select count(distinct (name)) as num_of_uniq_clients,
       avg(amount)            as avg_amount,
       sum(amount)            as total_amount,
       s.date                 as date
from client as c
         left join sell s on c.id = s.client_id
group by s.date
order by s.date;

select num_of_uniq_clients, avg_amount, total_amount
from client_view;

/* b. find top 5 dates with the greatest total sell amount */
create view date_tot_sell as
select sum(amount) as total_sell, date
from sell
group by date
order by total_sell desc;

select date, total_sell
from date_tot_sell
limit 5;

/* c. count the number of sales, compute average and total amount
   of all sales of each dealer */
create view dealer_info as
select count(id)   as num_sales,
       avg(amount) as avg_amt,
       sum(amount) as tot_amt,
       dealer_id
from sell
group by dealer_id;

select num_sales, avg_amt, tot_amt, name
from dealer_info as di
         inner join dealer d on d.id = di.dealer_id;

/* d. compute how much all dealers
   earned from charge(total sell amount * charge) in each location */
create or replace view charge_earned as
select sum(earned) as all_earnings
from (select d.id as id, name, location, charge, amount, charge * amount as earned
      from dealer as d
               inner join sell as s on s.dealer_id = d.id) as dealer_sell
group by location;

select *
from charge_earned;

/* e. compute number of sales,
   average and total amount of all sales dealers made in each location */
create or replace view sale_by_loc as
select count(s.id) as num_sales, avg(amount) as avg_amt, sum(amount) as tot_amt
from sell as s
         inner join dealer d on s.dealer_id = d.id
group by location;

select *
from sale_by_loc;

/* f. compute number of sales,
   average and total amount of expenses in each city clients made. */
create view client_purchase as
select count(s.id) as num_of_sale, avg(amount) as avg_exps, sum(amount) as tot_exps, city
from client as c
         inner join sell s on c.id = s.client_id
group by city;

select *
from client_purchase;

/* g. find cities where total expenses more than total amount of sales in locations */
select distinct(city) from client_purchase as cp, sale_by_loc as sl
where cp.tot_exps > sl.tot_amt;