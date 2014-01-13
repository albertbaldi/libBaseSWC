import mx.formatters.DateFormatter;

package valueObjects
{
	public var key:String;
	public var value:Object;
	
	public WhereVO(key:String, value:Object):void
	{
		this.key = key;
		this.value = value;
	}
	
	public get formattedKey():String
	{
		if(value is Date)
			return 'date(' + key + ')';
			
		return key.toString();
	}
	
	public get formattedValue():String
	{
		if(value is Date)
		{
			var df:DateFormatter = new DateFormatter;
			df.formatString = 'YYYY-MM-DD';
			return df.format(value);
		}	
		
		return value.toString();
	}
	
	/*
	for each(var where:WhereVO in arWhere)
	{
			//insere o item na query
			sql += where.formattedKey + '=:' + where.key;
			if(arWhere.indexOf(where) < arWhere.length)
				sql += ' AND ';
			
			//insere o item no parametro
			stmt.parameters[':' + where.key] = where.formattedValue;
	}	
	*/
}
