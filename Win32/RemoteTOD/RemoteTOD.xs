#ifndef UNICODE
#define UNICODE 1
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <windows.h> 
#include <lm.h>


MODULE = Win32::RemoteTOD		PACKAGE = Win32::RemoteTOD		

SV *
GetTOD(host)
		char *host
	INIT:
		LPTIME_OF_DAY_INFO pBuf = NULL;
		NET_API_STATUS nStatus = 0;
		LPTSTR pszServerName = NULL;
		HV *results;

		results = (HV *)sv_2mortal((SV *)newHV());
		pszServerName = malloc( (strlen(host)+1) * sizeof(wchar_t));
		if (pszServerName == NULL) {
			XSRETURN_UNDEF;
		}
		mbstowcs(pszServerName, host, strlen(host));
	CODE:
		nStatus = NetRemoteTOD(pszServerName,(LPBYTE *)&pBuf);
		free(pszServerName);

		if ((nStatus == NERR_Success) && (pBuf != NULL)) {
			// set hash
			hv_store(results, "elapsedt",	8, newSViv(pBuf->tod_elapsedt),		0);
			hv_store(results, "msecs",	5, newSViv(pBuf->tod_msecs),		0);
			hv_store(results, "hours",	5, newSViv(pBuf->tod_hours),		0);
			hv_store(results, "mins",	4, newSViv(pBuf->tod_mins),		0);
			hv_store(results, "secs",	4, newSViv(pBuf->tod_secs),		0);
			hv_store(results, "hunds",	5, newSViv(pBuf->tod_hunds),		0);
			hv_store(results, "timezone",	8, newSViv(pBuf->tod_timezone),		0);
			hv_store(results, "tinterval",	9, newSViv(pBuf->tod_tinterval),	0);
			hv_store(results, "day",	3, newSViv(pBuf->tod_day),		0);
			hv_store(results, "month",	5, newSViv(pBuf->tod_month),		0);
			hv_store(results, "year",	4, newSViv(pBuf->tod_year),		0);
			hv_store(results, "weekday",	7, newSViv(pBuf->tod_weekday),		0);

			RETVAL = newRV_inc((SV *)results);
			if (pBuf != NULL) NetApiBufferFree(pBuf);
		}
		else {
			if (pBuf != NULL) NetApiBufferFree(pBuf);
			XSRETURN_UNDEF;
		}
	OUTPUT:
		RETVAL
