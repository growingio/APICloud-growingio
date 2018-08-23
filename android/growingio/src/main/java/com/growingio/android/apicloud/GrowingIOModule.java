package com.growingio.android.apicloud;

import org.json.JSONObject;
import android.app.Application;
import android.text.TextUtils;

import com.growingio.android.sdk.collection.Configuration;
import com.growingio.android.sdk.collection.CoreInitialize;
import com.growingio.android.sdk.collection.GrowingIO;
import com.growingio.android.sdk.collection.SessionManager;
import com.growingio.android.sdk.utils.LogUtil;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

/**
 * GrowingIO的API Cloud 桥映射文件
 * @author 梁登科
 */
public class GrowingIOModule extends UZModule {

	private static boolean hasInit = false;
	private static final String GROWINGIO = "GrowingIO";

	public GrowingIOModule(UZWebView webView) {
		super(webView);
	}

	private String getValue(String key){
		return getFeatureValue(GROWINGIO, key);
	}

	/**
	 * 暴露的Feature
	 * {
	 *     "android_accountId": "",
	 *     "android_urlScheme": "",
	 *     "debug": "",
	 *     "channel": "",
	 *     "zone": "",
	 *     "gtaHost": "",
	 *     "dataHost":"",
	 *     "reportHost":"",
	 *     "trackerHost":"",
	 *     "wsHost":""
	 * }
	 */
	private void init(Application application) {
		String accountId = getValue("android_accountId");
		String urlScheme = getValue("android_urlScheme");
		if (TextUtils.isEmpty(accountId) || TextUtils.isEmpty(urlScheme)){
			throw new IllegalArgumentException("accountId and urlScheme must not be null");
		}
		Configuration configuration = new Configuration();
		configuration.setProjectId(accountId);
		configuration.setURLScheme(urlScheme);
		String debug = getValue("debug");
		if (!TextUtils.isEmpty(debug)){
			boolean isDebug = "true".equals(debug.toLowerCase());
			configuration.setDebugMode(isDebug);
			configuration.setTestMode(isDebug);
		}
		String channel = getValue("channel");
		if (!TextUtils.isEmpty(channel)){
			configuration.setChannel(channel);
		}
		String zone = getValue("zone");
		if (!TextUtils.isEmpty(zone)){
			configuration.setZone(zone);
		}
		String gtaHost = getValue("gtaHost");
		if (!TextUtils.isEmpty(gtaHost)){
			configuration.setGtaHost(gtaHost);
		}
		String dataHost = getValue("dataHost");
		if (!TextUtils.isEmpty(dataHost)){
			configuration.setDataHost(dataHost);
		}
		String reportHost = getValue("reportHost");
		if (!TextUtils.isEmpty(reportHost)){
			configuration.setReportHost(reportHost);
		}
		String wsHost = getValue("wsHost");
		if (!TextUtils.isEmpty(wsHost)){
			configuration.setWsHost(wsHost);
		}
		String trackerHost = getValue("trackerHost");
		if (!TextUtils.isEmpty(trackerHost)){
			configuration.setTrackerHost(trackerHost);
		}
		configuration.setRnMode(true);
		GrowingIO.startWithConfiguration(application, configuration);
		CoreInitialize.coreAppState().setForegroundActivity(GrowingIOAppState.currentActivity());
		SessionManager.onActivityResume();
		LogUtil.d(GROWINGIO, "初始化结束");
	}

	private void success(UZModuleContext context){
		context.success("{\"status\":true, \"msg\": \"success\"}", true, true);
	}

	public void jsmethod_init(UZModuleContext context){
		if (!hasInit){
			Application application = (Application) context.getContext().getApplicationContext();
			init(application);
			hasInit = true;
		}
	}


	public void jsmethod_track(UZModuleContext moduleContext){
		String eventId = optString(moduleContext, "eventId");
		JSONObject eventLevelVariable = moduleContext.optJSONObject("eventLevelVariable");
		Double number = moduleContext.optDouble("number", 0);
		if (Math.abs(number - 0) > 0.0000001){
			if (eventLevelVariable != null){
				GrowingIO.getInstance().track(eventId, number, eventLevelVariable);
			}else{
				GrowingIO.getInstance().track(eventId, number);
			}
		}else{
			if (eventLevelVariable == null){
				GrowingIO.getInstance().track(eventId);
			}else{
				GrowingIO.getInstance().track(eventId, eventLevelVariable);
			}
		}
		success(moduleContext);
	}

	public void jsmethod_setUserId(UZModuleContext moduleContext){
		String userId = optString(moduleContext, "userId");
		GrowingIO.getInstance().setUserId(userId);
		success(moduleContext);
	}

	public void jsmethod_clearUserId(UZModuleContext moduleContext){
		GrowingIO.getInstance().clearUserId();
		success(moduleContext);
	}

	public void jsmethod_setEvar(UZModuleContext moduleContext){
		JSONObject conversionVariables = moduleContext.get();
		GrowingIO.getInstance().setEvar(conversionVariables);
		success(moduleContext);
	}

	public void jsmethod_setPeopleVariable(UZModuleContext moduleContext){
		JSONObject peopleVariable = moduleContext.get();
		GrowingIO.getInstance().setPeopleVariable(peopleVariable);
		success(moduleContext);
	}

	private String optString(UZModuleContext context, String key){
		String result = context.optString(key);
		if ("null".equals(result)){
			JSONObject object = context.optJSONObject(key);
			if (object == null || object.length() == 0)
				result = null;
		}
		return result;
	}
}
