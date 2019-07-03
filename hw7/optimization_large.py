#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 20:29:44 2019

@author: alifahsanul
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 00:52:07 2019

@author: alifahsanul

Diet problem

"""

import pulp
import pandas as pd

excel_df = pd.read_excel('diet_large.xls', skiprows=1)

nutrient_names = list(excel_df.columns)[1:]

nutrient_df = excel_df[:-4]
nutrient_df = nutrient_df[list(nutrient_df.columns)[:]]
nutrient_df = nutrient_df.fillna(0)

min_daily_df = excel_df[-3:]
min_daily_df = min_daily_df[0:1]
min_daily_df = min_daily_df[nutrient_names[:]]
min_daily_dict = {k:v for (k,v) in zip(list(min_daily_df.columns), min_daily_df.values[0])}

max_daily_df = excel_df[-3:]
max_daily_df = max_daily_df[2:3]
max_daily_df = max_daily_df[nutrient_names[:]]
max_daily_dict = {k:v for (k,v) in zip(list(max_daily_df.columns), max_daily_df.values[0])}

Ingredients = list(nutrient_df['Long_Desc'])
cholesterol = {k: (v1+v2+v3) for (k, v1, v2, v3) in 
               zip(Ingredients, 
                   list(nutrient_df['Cholesterol']), 
                   list(nutrient_df['Fatty acids, total trans']), 
                   list(nutrient_df['Fatty acids, total saturated'])
                   )
               }

prob = pulp.LpProblem(name='Diet Problem', sense=pulp.LpMinimize)

ingredient_vars = pulp.LpVariable.dicts('Ingr', Ingredients, 0, 100)

prob += pulp.lpSum(cholesterol[i] * ingredient_vars[i] for i in Ingredients), 'Total Cholesterol amount of Ingredients per can'

for nutrient in nutrient_names:
    if nutrient in ['Cholesterol', 
                    'Fatty acids, total trans', 
                    'Fatty acids, total saturated']:
        continue
    assert len(Ingredients) == len(nutrient_df)
    ingredient_content = {k: v for (k, v) in zip(Ingredients, list(nutrient_df[nutrient]))}
    assert len(ingredient_content) == len(ingredient_vars)
    prob += pulp.lpSum([ingredient_content[i] * ingredient_vars[i] for i in Ingredients]) >= min_daily_dict[nutrient], 'min{}'.format(nutrient)
    prob += pulp.lpSum([ingredient_content[i] * ingredient_vars[i] for i in Ingredients]) <= max_daily_dict[nutrient], 'max{}'.format(nutrient)

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

final_ingr_name.append('Total Cholesterol')
final_ingr_amount.append(pulp.value(prob.objective))

result_df = pd.DataFrame({'amount': final_ingr_amount})
result_df.index = final_ingr_name
result_df.to_excel('large_diet_opt_result.xlsx')

print('Ingredient:')
print(result_df)
print('Total Cholesterol of Food = ', pulp.value(prob.objective))

























