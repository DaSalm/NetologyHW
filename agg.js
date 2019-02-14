/* расчёт количества тегов
*/
print("tags count: ",db.tags.count());

/*количество тегов woman
*/
print("woman tags count: ",db.tags.count({name:"woman"}));


/*
        Очень сложный запрос:
*/
printjson(
	db.tags.aggregate([
		{$group: {
				_id: "$name",
				 tag_count: { $sum: 1 }
			}
		},
		{$sort:{tag_count: -1}},
		{$limit: 3}
	]) ['_batch']
);
