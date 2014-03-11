import json
import csv

results = json.load(file('data.json'))

with open('eggs.csv', 'wb') as csvfile:
    spamwriter = csv.writer(csvfile)

    for r in results:
        spamwriter.writerow([r['input']['numberOfItems'], r['input']['searchRatio'] * r['input']['searchRatio'], r['NIMQuadTreeOBJC']['insert'], r['NIMQuadTree']['insert']])

    # spamwriter.writerow(['Spam'] * 5 + ['Baked Beans'])
    # spamwriter.writerow(['Spam', 'Lovely Spam', 'Wonderful Spam'])
