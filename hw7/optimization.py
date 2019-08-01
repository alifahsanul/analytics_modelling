#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 00:52:07 2019

@author: alifahsanul

Diet problem

"""

import pulp
import pandas as pd

problem_number = 1 #1 or 2

excel_df = pd.read_excel('diet.xls')

nutrient_df = excel_df[:-3]
nutrient_names = list(excel_df.columns)[3:]

min_daily_df = excel_df[-3:]
min_daily_df = min_daily_df[1:2]
min_daily_df = min_daily_df[nutrient_names]
min_daily_dict = {k:v for (k,v) in zip(list(min_daily_df.columns), min_daily_df.values[0])}

max_daily_df = excel_df[-3:]
max_daily_df = max_daily_df[2:3]
max_daily_df = max_daily_df[nutrient_names]
max_daily_dict = {k:v for (k,v) in zip(list(max_daily_df.columns), max_daily_df.values[0])}

Ingredients = list(nutrient_df['Foods'])
costs = {k: v for (k, v) in zip(Ingredients, list(nutrient_df['Price/ Serving']))}

prob = pulp.LpProblem(name='Diet Problem', sense=pulp.LpMinimize)

ingredient_vars = pulp.LpVariable.dicts('Ingr', Ingredients, 0, 100)
is_chosen_vars = pulp.LpVariable.dicts('Chosen', Ingredients, 0, 1, cat = "Binary")

prob += pulp.lpSum(costs[i] * ingredient_vars[i] for i in Ingredients), 'Total Cost of Ingredients per can'

for nutrient in nutrient_names:
    assert len(Ingredients) == len(nutrient_df)
    ingredient_content = {k: v for (k, v) in zip(Ingredients, list(nutrient_df[nutrient]))}
    assert len(ingredient_content) == len(ingredient_vars)
    prob += pulp.lpSum([ingredient_content[i] * ingredient_vars[i] for i in Ingredients]) >= min_daily_dict[nutrient], 'min{}'.format(nutrient)
    prob += pulp.lpSum([ingredient_content[i] * ingredient_vars[i] for i in Ingredients]) <= max_daily_dict[nutrient], 'max{}'.format(nutrient)

if problem_number == 1:
    pass
elif problem_number == 2:
    for ingr in Ingredients:
        prob += is_chosen_vars[ingr] <= ingredient_vars[ingr] * 99999999999999
        prob += is_chosen_vars[ingr] >= ingredient_vars[ingr] * 0.0000000000001 #this is actually redundant with below constraint
        prob += ingredient_vars[ingr] >= is_chosen_vars[ingr] * 0.1
    
    prob += is_chosen_vars['Celery, Raw'] + is_chosen_vars['Frozen Broccoli'] <= 1
    prob += is_chosen_vars['Roasted Chicken'] + is_chosen_vars['Poached Eggs'] + is_chosen_vars['Scrambled Eggs'] + is_chosen_vars['Bologna,Turkey'] + is_chosen_vars['Ham,Sliced,Extralean'] + is_chosen_vars['Hamburger W/Toppings'] + is_chosen_vars['Hotdog, Plain'] + is_chosen_vars['Pork'] + is_chosen_vars['Sardines in Oil'] + is_chosen_vars['White Tuna in Water'] >= 3
    pass
else:
    raise ValueError

prob.writeLP('DietModel.lp')
prob.solve()
print('Status:', pulp.LpStatus[prob.status])

result_dict = {}
final_ingr_name = []
final_ingr_amount = []

for v in prob.variables():
    result_dict[v.name] = v.varValue
    if v.varValue > 0:
        final_ingr_name.append(v.name[5:])
        final_ingr_amount.append(v.varValue)


final_ingr_name.append('Total Cost')
final_ingr_amount.append(pulp.value(prob.objective))

result_df = pd.DataFrame({'amount': final_ingr_amount})
result_df.index = final_ingr_name
result_df.to_excel('diet_opt_result_number_{}.xlsx'.format(problem_number))

print('Ingredient:')
print(result_df)
print('Total Cholesterol of Food = ', pulp.value(prob.objective))

























