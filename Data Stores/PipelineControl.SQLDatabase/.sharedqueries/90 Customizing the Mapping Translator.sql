/*

The data in the [CopyActivitySettings] column is currently set to '{ "translator": null }' for all rows. The Copy Data
tasks in the Bottom Level Pipeline needs this to satisfy the expression: JSON_VALUE([CopyActivitySettings], '$.translator')      AS [MappingTranslator]
in the view definition. 

If NO translations are happening, then the [MappingTranslator] can be null. But if you need to do any translations, you should
follow the below sample:

{
	"translator": {
		"type": "TabularTranslator",
		"mappings": [
			{
				"source": {
					"name": "Column1",
					"type": "Int32"
				},
				"sink": {
					"name": "Column1",
					"type": "Int32"
				}
			},
			{
				"source": {
					"name": "Column2",
					"type": "String"
				},
				"sink": {
					"name": "Column2",
					"type": "String"
				}
			},
			{
				"source": {
					"name": "Column3",
					"type": "Boolean"
				},
				"sink": {
					"name": "Column3",
					"type": "Boolean"
				}
			},
			{
				"source": {
					"name": "Column4",
					"type": "Decimal"
				},
				"sink": {
					"name": "Column4",
					"type": "Decimal"
				}
			}
		]
	}
}

*/