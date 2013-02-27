package tl.utils
{

	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ObjectToMappedObject
	{
		private static const vectorPrefix : String = "__AS3__.vec::Vector.";

		public static function parseObject( obj : *, objectClass : Class = null ) : *
		{
			if ( objectIsSimple( obj ) )
			{
				return obj;
			}

			// Parsing vector
			if ( objectClass != null && obj is Array )
			{
				const resultVector : * = new (objectClass)();

				const qualifiedClassName : String = getQualifiedClassName( objectClass );
				const vectorInnerTypeString : String = qualifiedClassName.substr( vectorPrefix.length + 1, qualifiedClassName.length - vectorPrefix.length - 2 );
				const vectorInnerType : Class = typeStringIsSimple( vectorInnerTypeString ) ? null : ApplicationDomain.currentDomain.getDefinition( vectorInnerTypeString ) as Class;

				for each( var innerData : * in obj )
				{
					resultVector.push( parseObject( innerData, vectorInnerType ) );
				}

				return resultVector;
			}

			// Parsing array
			if ( obj is Array )
			{
				const resultArray : Array = [];

				for each( var innerVectorData : * in obj )
				{
					resultArray.push( parseObject( innerVectorData ) );
				}

				return resultArray;
			}

			// Parsing object
			if ( objectClass != null )
			{

			}
			else if ( obj.hasOwnProperty( "new" ) )
			{
				objectClass = ApplicationDomain.currentDomain.getDefinition( obj["new"] ) as Class;
			}
			else
			{
				objectClass = Object;
			}

			var instance : Object = new (objectClass)();

			var desc : XMLList = describeTypeCached( instance ).variable;

			for ( var prop : String in obj )
			{
				if ( prop == "new" )
				{
					continue;
				}

				var propertyType : String = desc.(@name.toString() == prop).@type.toString();

				// If type isn't founded, or it's simple type
				if ( typeStringIsSimple( propertyType ) )
				{
					instance[prop] = obj[prop];
				}
				// Else (if it's Object, or some custom type) just parse it recursive
				else
				{
					instance[prop] = parseObject( obj[prop], getDefinitionByName( propertyType ) as Class );
				}
			}

			return instance;
		}

		public static function typeStringIsSimple( type : String ) : Boolean
		{
			// (See ECMAScript specs)
			return ( type == "" ||
					type == "String" ||
					type == "Number" ||
					type == "uint" ||
					type == "int" ||
					type == "Boolean"
					);
		}

		public static function objectIsSimple( obj : * ) : Boolean
		{
			return obj is String ||
					obj is Number ||
					obj is uint ||
					obj is int ||
					obj is Boolean;
		}
	}
}
