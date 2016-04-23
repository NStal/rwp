# What for?

1. create A RSS for some list-like parts of the page. It can be a comment list, a reply list of a thread, a update list of a commic.
2. watch some single part of the page, and also create rss when it changes.

I now have to complete the first group. And make an choice at the entry to allow choose second method, and then complete the method.

# How (for method 1)
Generally , we use plugin to interact with user, user can choose a item, we infer a list/item from what user choose.

Details:
1. Algorithm. we use alignment/repeat charactor/repeat count to identify the correct list.
2. We allow user to choose from some candidates.
3. We allow user to choose what part of the list item is wanted.
4. finally generate a JSON object and encode to base64 and dump like rwp://{base64string}.
5. user add this rwp protocol string to whatever end point to fetch actually generate the rss.
6. how to generate rss? we watch the page, find the list by rwp info, extract list items by rwp info. build guid for each item and see if there are any changes. And finally generate the rss list.
7. 
