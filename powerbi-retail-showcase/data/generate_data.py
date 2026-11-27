"""Generate the synthetic retail dataset used by the Retail Sales report.

All names and figures are invented. The data has a few patterns built in
so the report has something to find:
  - seasonality: peaks in March-April and November-December
  - online share grows from about 12% to 22% over two years
  - Abu Dhabi stores were given targets that are too high
  - sale periods (late Nov to mid Jan, July) have deeper discounts and lower margin

Run: python generate_data.py   (writes CSV files next to this script)
"""
import csv
import math
import os
import random
from datetime import date, timedelta

random.seed(42)
OUT = os.path.dirname(os.path.abspath(__file__))
START, END = date(2024, 1, 1), date(2025, 12, 31)

# ---------------------------------------------------------------- stores
STORES = [
    # name, city, region, format, size factor
    ("Marina", "Dubai", "Dubai", "Mall", 1.35),
    ("Deira", "Dubai", "Dubai", "High Street", 1.10),
    ("Al Barsha", "Dubai", "Dubai", "Mall", 1.25),
    ("JLT", "Dubai", "Dubai", "Community", 0.80),
    ("Mirdif", "Dubai", "Dubai", "Mall", 1.15),
    ("Business Bay", "Dubai", "Dubai", "Community", 0.85),
    ("Karama", "Dubai", "Dubai", "High Street", 0.90),
    ("Silicon Oasis", "Dubai", "Dubai", "Outlet", 0.95),
    ("Khalifa City", "Abu Dhabi", "Abu Dhabi", "Community", 0.80),
    ("Al Reem", "Abu Dhabi", "Abu Dhabi", "Mall", 1.20),
    ("Mussafah", "Abu Dhabi", "Abu Dhabi", "Outlet", 0.90),
    ("Yas", "Abu Dhabi", "Abu Dhabi", "Mall", 1.30),
    ("Corniche", "Abu Dhabi", "Abu Dhabi", "High Street", 0.85),
    ("Al Ain Central", "Al Ain", "Abu Dhabi", "Mall", 0.95),
    ("Al Jimi", "Al Ain", "Abu Dhabi", "Community", 0.70),
    ("Al Nahda", "Sharjah", "Sharjah", "Community", 0.85),
    ("Al Majaz", "Sharjah", "Sharjah", "Mall", 1.05),
    ("Muwaileh", "Sharjah", "Sharjah", "Outlet", 0.90),
    ("Al Qasimia", "Sharjah", "Sharjah", "High Street", 0.75),
    ("Ajman", "Ajman", "Northern Emirates", "Mall", 0.85),
    ("Ras Al Khaimah", "Ras Al Khaimah", "Northern Emirates", "Mall", 0.90),
    ("Fujairah", "Fujairah", "Northern Emirates", "Community", 0.70),
]
REGION_TARGET_BIAS = {"Dubai": 0.94, "Abu Dhabi": 1.12, "Sharjah": 1.00, "Northern Emirates": 0.98}

# -------------------------------------------------------------- products
CATALOGUE = {
    "Electronics": {"Audio": (90, 900), "Phones & Tablets": (600, 4500), "Smart Home": (120, 1200)},
    "Home": {"Kitchen": (40, 700), "Bedding": (60, 900), "Decor": (25, 450)},
    "Apparel": {"Womenswear": (60, 600), "Menswear": (60, 550), "Kidswear": (30, 250)},
    "Beauty": {"Skincare": (35, 450), "Fragrance": (150, 950), "Haircare": (20, 220)},
}
MARGIN = {"Electronics": 0.24, "Home": 0.46, "Apparel": 0.55, "Beauty": 0.50}
DISCOUNT_SENSITIVE = {"Phones & Tablets", "Womenswear", "Menswear", "Fragrance"}
BRANDS = ["Northline", "Kestrel", "Alder & Co", "Meridian", "Sable", "Orra", "Lumen", "Tavira"]
CATEGORY_WEIGHT = {"Electronics": 0.9, "Home": 1.0, "Apparel": 1.4, "Beauty": 1.2}


def seasonality(d):
    m = d.month
    base = {1: 0.85, 2: 0.85, 3: 1.15, 4: 1.20, 5: 0.95, 6: 0.85, 7: 0.80,
            8: 0.85, 9: 0.95, 10: 1.00, 11: 1.25, 12: 1.40}[m]
    weekend = 1.25 if d.weekday() in (4, 5) else 1.0      # Friday, Saturday
    return base * weekend


def promo_depth(d):
    """Typical discount on a given day: deeper in sale periods."""
    if d.month in (11, 12) and d.day >= 20 or (d.month == 1 and d.day <= 15):
        return [0, 0.1, 0.2, 0.3, 0.4], [0.25, 0.2, 0.25, 0.2, 0.1]
    if d.month == 7:
        return [0, 0.1, 0.2, 0.3], [0.35, 0.25, 0.25, 0.15]
    return [0, 0.1, 0.2], [0.75, 0.18, 0.07]


def main():
    # stores
    with open(os.path.join(OUT, "store.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["StoreKey", "Store", "City", "Region", "Format"])
        for i, (name, city, region, fmt, _) in enumerate(STORES, 1):
            w.writerow([i, name, city, region, fmt])

    # channels
    with open(os.path.join(OUT, "channel.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Channel"])
        w.writerows([["In-store"], ["Online"]])

    # products
    products = []
    key = 0
    for cat, subs in CATALOGUE.items():
        for sub, (lo, hi) in subs.items():
            for brand in random.sample(BRANDS, 5):
                for n in range(2):
                    key += 1
                    price = round(math.exp(random.uniform(math.log(lo), math.log(hi))), -0 if hi < 300 else -1) - 0.01
                    price = max(price, lo - 0.01)
                    cost = round(price * (1 - MARGIN[cat] + random.uniform(-0.05, 0.05)), 2)
                    products.append((key, f"{brand} {sub} {('Essential', 'Premium')[n]}", sub, cat, brand,
                                     round(price, 2), cost))
    with open(os.path.join(OUT, "product.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["ProductKey", "Product", "Subcategory", "Category", "Brand", "ListPrice", "UnitCost"])
        w.writerows(products)
    weights = [CATEGORY_WEIGHT[p[3]] / (p[5] ** 0.35) for p in products]

    # dates
    days = []
    d = START
    while d <= END:
        days.append(d)
        d += timedelta(days=1)
    with open(os.path.join(OUT, "date.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Date", "Year", "Quarter", "MonthNo", "Month", "YearMonth", "Year Month", "Weekday", "WeekdayNo"])
        for d in days:
            w.writerow([d.isoformat(), d.year, f"Q{(d.month - 1) // 3 + 1}", d.month, d.strftime("%b"),
                        d.year * 100 + d.month, d.strftime("%b %Y"), d.strftime("%a"), d.isoweekday()])

    # sales
    monthly = {}
    line_id = 0
    total_days = (END - START).days
    with open(os.path.join(OUT, "sales.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["SalesLineID", "OrderDate", "StoreKey", "ProductKey", "Channel", "Quantity",
                    "UnitPrice", "GrossAmount", "DiscountAmount", "NetAmount", "Cost"])
        for d in days:
            t = (d - START).days / total_days
            trend = 1 + 0.10 * t
            online_share = 0.12 + 0.10 * t
            depths, probs = promo_depth(d)
            for s, (name, city, region, fmt, size) in enumerate(STORES, 1):
                lam = 7.5 * size * seasonality(d) * trend
                n = max(0, int(random.gauss(lam, math.sqrt(lam))))
                for p in random.choices(products, weights=weights, k=n):
                    pk, _, sub, cat, _, price, cost = p
                    disc = random.choices(depths, probs)[0]
                    if fmt == "Outlet":
                        disc = min(0.5, disc + 0.1)
                    qty = random.choices([1, 2, 3, 4], [0.7, 0.2, 0.07, 0.03])[0]
                    if disc and sub in DISCOUNT_SENSITIVE:
                        qty += random.choice([0, 1])
                    gross = round(price * qty, 2)
                    disc_amt = round(gross * disc, 2)
                    line_id += 1
                    channel = "Online" if random.random() < online_share else "In-store"
                    w.writerow([line_id, d.isoformat(), s, pk, channel, qty, price, gross,
                                disc_amt, round(gross - disc_amt, 2), round(cost * qty, 2)])
                    monthly[(s, d.year * 100 + d.month)] = monthly.get((s, d.year * 100 + d.month), 0) + gross - disc_amt

    # monthly targets: last year's expected level plus growth, with a regional bias
    with open(os.path.join(OUT, "target.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["StoreKey", "YearMonth", "TargetAmount"])
        for (s, ym), actual in sorted(monthly.items()):
            region = STORES[s - 1][2]
            target = actual * REGION_TARGET_BIAS[region] * random.uniform(0.96, 1.06)
            w.writerow([s, ym, round(target, -2)])

    print(f"{len(STORES)} stores, {len(products)} products, {len(days)} days, {line_id} sales lines")


if __name__ == "__main__":
    main()
