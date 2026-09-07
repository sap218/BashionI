# Python data faker

import pandas as pd
from faker import Faker
import random
from datetime import date

Faker.seed(21131427)
fake = Faker("en_GB")

def create_row():
    products = random.choice([
        "Tshirt", "Shirt", "Polo",
        "Trousers", "Jeans", "Joggers",
        "Coat", "Jacket",
        "Jewellery", "Hat",
        "Sneakers", "Trainers", "Boots"
    ])
    if products in ["Tshirt", "Shirt", "Polo"]: category = "Tops"
    elif products in ["Trousers", "Jeans", "Joggers"]: category = "Bottoms"
    elif products in ["Coat", "Jacket"]: category = "Outerwear"
    elif products in ["Jewellery", "Hat"]: category = "Accessories"
    elif products in ["Sneakers", "Trainers", "Boots"]: category = "Footwear"
    else: category = "Other"

    dates = fake.date_between(start_date=date(2025, 1, 1), end_date=date(2025, 12, 31))
    month = dates.strftime("%B")

    ages = max(18, min(65, round(random.gauss(28, 10))))
    if ages <= 24: age_group = "18-24"
    elif ages <= 34: age_group = "25-34"
    elif ages <= 44: age_group = "35-44"
    elif ages <= 54: age_group = "45-54"
    elif ages <= 64: age_group = "55-64" 
    else: age_group = "65+"

    return {
        "First_name": fake.first_name(),
        "Last_name": "NA", #"Full_name": fake.name(),
        "Email": "NA", #fake.email(),
        
        #"Age": max(18, min(65, round(random.gauss(28, 10)))), # random.randint(18, 65),
        "Age": ages,
        "AgeGroup": age_group,

        "Gender": random.choices(["Female","Male","Non-binary","Genderfluid","Other"], weights=[60, 25, 7, 5, 3])[0],

        #"Date": fake.date_between(start_date=date(2025, 1, 1), end_date=date(2025, 12, 31)),
        "Date": dates,
        "Month": month,
        
        "Cost": round(random.uniform(20, 100), 2), # (30_000, 100_000)
        "Quantity": random.choices([1, 2, 3, 4], weights=[85, 10, 4, 1])[0], # Revenue = Cost * Quantity
        "Product": products,
        "Category": category,
        "Colour": random.choices(["Black","White","Grey","Brown","Beige","Red","Orange","Yellow","Green","Blue","Purple","Pink"],
                                 weights=[30, 10, 10, 20, 5, 5, 1, 1, 2, 5, 2, 3])[0],
        "OnSale": random.choices(["Yes","No"], weights=[20, 80])[0],
        "PurchasedVia": random.choices(["Website","App","In-store"], weights=[30, 10, 60])[0],

        #"City": fake.city(),
        "City": random.choices(["Bath","Birmingham","Brighton","Cardiff","Glasgow","Liverpool","London","Nottingham",],
                               weights=[13, 8, 10, 14, 5, 16, 30, 4])[0],

        "Stars": max(1, min(5, round(random.gauss(4, 1)))), # random.randint(1, 5),
        "Happiness": max(1, min(5, round(random.gauss(4, 1)))),
        "Recommendation": random.choices(["Yes","No","NA"], weights=[35, 5, 60])[0],
    }

row_count = 10000
RowID = range(1, row_count + 1)
df = pd.DataFrame([create_row() for _ in range(row_count)])
df["RowID"] = RowID
df = df.iloc[:, [-1] + list(range(df.shape[1] - 1))]

#print(df.head(9))

df.to_csv("data/fake_data.tsv", index=False, sep="\t")

# End
