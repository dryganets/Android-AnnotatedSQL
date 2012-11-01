<#function getMathcName path>
	<#return path?upper_case?replace(".", "_")?replace(" + \"/#\"", "_ITEM")>
</#function>
/* AUTO-GENERATED FILE.  DO NOT MODIFY.
 *
 * This class was automatically generated by the AnnotatedSQL library.
  */
package ${pkgName};

<#list imports as import>
import ${import};	 
</#list> 
		
import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.text.TextUtils;

public class ${className} extends ContentProvider{

	public static final String AUTHORITY = "${authority}";
	private static final String FRAGMENT_NO_NOTIFY = "no-notify";
	private static final Uri BASE_URI = Uri.parse("content://" + AUTHORITY);

	private final static int MATCH_TYPE_ITEM = 0x0001;
	private final static int MATCH_TYPE_DIR = 0x0002;
	private final static int MATCH_TYPE_MASK = 0x000f;
	
	<#list entities as e>
	private final static int MATCH_${getMathcName(e.path)} = ${e.codeHex};
	</#list>
	
	private static final UriMatcher matcher = new UriMatcher(UriMatcher.NO_MATCH);

	static {
		<#list entities as e>
		matcher.addURI(AUTHORITY, ${e.path}, MATCH_${getMathcName(e.path)}); 
		</#list> 
	}
	
	private SQLiteOpenHelper dbHelper;
	private ContentResolver contentResolver;

	@Override
	public boolean onCreate() {
		final Context context = getContext();
		dbHelper = new AnnotationSql(context);
		contentResolver = context.getContentResolver();
		return true;
	}
	
	@Override
	public String getType(Uri uri) {
		final String type;
		switch (matcher.match(uri) & MATCH_TYPE_MASK) {
			case MATCH_TYPE_ITEM:
				type = ContentResolver.CURSOR_ITEM_BASE_TYPE + "/vnd." + AUTHORITY + ".item";
				break;
			case MATCH_TYPE_DIR:
				type = ContentResolver.CURSOR_DIR_BASE_TYPE + "/vnd." + AUTHORITY + ".dir";
				break;
			default:
				throw new IllegalArgumentException("Unsupported uri " + uri);
			}
		return type;
	}

	@Override
	public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
		final SQLiteQueryBuilder query = new SQLiteQueryBuilder();
		String groupBy = null;
		switch (matcher.match(uri)) {
			<#list entities as e>
			case MATCH_${getMathcName(e.path)}:{
				query.setTables(${e.tableLink});
				<#if e.item>
				query.appendWhere("${e.selectColumn} = " + uri.getLastPathSegment());
				</#if>
				break;
			}
			</#list> 
			default:
				throw new IllegalArgumentException("Unsupported uri " + uri);
		}
		Cursor c = query.query(dbHelper.getReadableDatabase(),
        		projection, selection, selectionArgs,
        		groupBy, null, sortOrder, null);
		c.setNotificationUri(getContext().getContentResolver(), uri);
		
		return c;
	}

	@Override
	public Uri insert(Uri uri, ContentValues values) {
		String table;
		Uri alternativeNotify = null;
		
		switch(matcher.match(uri)){
			<#list entities as e>
			<#if e.item>
			<#elseif e.onlyQuery>
			<#else>
			case MATCH_${getMathcName(e.path)}:{
				table = ${e.tableLink};
				<#if (e.altNotify?length > 0)>
				alternativeNotify = getContentUri("${e.altNotify}");
				</#if>
				break;
			}
			</#if>
			</#list> 
			default:
				throw new IllegalArgumentException("Unsupported uri " + uri);
		}
		dbHelper.getWritableDatabase().insertWithOnConflict(table, null, values, SQLiteDatabase.CONFLICT_REPLACE);
		if(!ignoreNotify(uri)){
			contentResolver.notifyChange(uri, null);
			if(alternativeNotify != null){
				contentResolver.notifyChange(alternativeNotify, null);
			}
		}
		return uri;
	}
	
	@Override
	public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		String table;
        String processedSelection = selection;
        Uri alternativeNotify = null;
        
		switch(matcher.match(uri)){
			<#list entities as e>
			<#if !e.onlyQuery>
			case MATCH_${getMathcName(e.path)}:{
				table = ${e.tableLink};
				<#if e.item>
				processedSelection = composeIdSelection(selection, uri.getLastPathSegment(), "${e.selectColumn}");
					<#if (e.altNotify?length > 0)>
				alternativeNotify = getContentUri("${e.altNotify}", uri.getLastPathSegment());
					</#if>
				<#elseif (e.altNotify?length > 0)>
				alternativeNotify = getContentUri("${e.altNotify}");
				</#if>
				break;
			}
			</#if>
			</#list> 
			default:
				throw new IllegalArgumentException("Unsupported uri " + uri);
		}
		int count = dbHelper.getWritableDatabase().update(table, values, processedSelection, selectionArgs);
		if(!ignoreNotify(uri)){
			contentResolver.notifyChange(uri, null);
			if(alternativeNotify != null){
				contentResolver.notifyChange(alternativeNotify, null);
			}
		}
		
		return count;
	}
	
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		String table;
        String processedSelection = selection;
        Uri alternativeNotify = null;
        
		switch(matcher.match(uri)){
			<#list entities as e>
			<#if !e.onlyQuery>
			case MATCH_${getMathcName(e.path)}:{
				table = ${e.tableLink};
				<#if e.item>
				processedSelection = composeIdSelection(selection, uri.getLastPathSegment(), "${e.selectColumn}");
					<#if (e.altNotify?length > 0)>
				alternativeNotify = getContentUri("${e.altNotify}", uri.getLastPathSegment());
					</#if>
				<#elseif (e.altNotify?length > 0)>
				alternativeNotify = getContentUri("${e.altNotify}");
				</#if>
				break;
			}
			</#if>
			</#list> 
			default:
				throw new IllegalArgumentException("Unsupported uri " + uri);
		}
		int count = dbHelper.getWritableDatabase().delete(table, processedSelection, selectionArgs)
		if(!ignoreNotify(uri)){
			contentResolver.notifyChange(uri, null);
			if(alternativeNotify != null){
				contentResolver.notifyChange(alternativeNotify, null);
			}
		}
		return count;
	}
	
	private static boolean ignoreNotify(Uri uri){
		return FRAGMENT_NO_NOTIFY.equals(uri.getFragment());
	}
	
	private String composeIdSelection(String originalSelection, String id, String idColumn) {
        StringBuffer sb = new StringBuffer();
        sb.append(idColumn).append('=').append(id);
        if (!TextUtils.isEmpty(originalSelection)) {
            sb.append(" AND (").append(originalSelection).append(')');
        }
        return sb.toString();
    }
 
 	public static Uri getContentUri(String path){
		if(TextUtils.isEmpty(path))
			return null;
		return BASE_URI.buildUpon().appendPath(path).build(); 
	}
	
	public static Uri getContentUri(String path, long id){
		if(TextUtils.isEmpty(path))
			return null;
		return BASE_URI.buildUpon().appendPath(path).appendPath(String.valueOf(id)).build(); 
	}
	
	public static Uri getContentUri(String path, String id){
		if(TextUtils.isEmpty(path))
			return null;
		return BASE_URI.buildUpon().appendPath(path).appendPath(id).build(); 
	}
	
	public static Uri getNoNotifyContentUri(String path){
		if(TextUtils.isEmpty(path))
			return null;
		return BASE_URI.buildUpon().appendPath(path).fragment(FRAGMENT_NO_NOTIFY).build(); 
	}
	
	public static Uri getNoNotifyContentUri(String path, long id){
		if(TextUtils.isEmpty(path))
			return null;
		return BASE_URI.buildUpon().appendPath(path).appendPath(String.valueOf(id)).fragment(FRAGMENT_NO_NOTIFY).build(); 
	}
	   
	private class AnnotationSql extends SQLiteOpenHelper {

		public AnnotationSql(Context context) {
			super(context, FStore.DB_NAME, null, FStore.DB_VERSION);
		}

		@Override
		public void onCreate(SQLiteDatabase db) {
			${schemaClassName}.onCreate(db);
		}

		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			${schemaClassName}.onDrop(db);
			onCreate(db);
		}

	}

}