# DELL XPS 15 7590 model patches

DF_DELL_MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DF_DELL := $(abspath $(dir $(DF_DELL_MAKEFILE_NAME)))

DF_DELL_FSROOT := $(DF_DELL)/fsroot

PKG_RPM += grubby

########################################################################################################################
#
# Package installation customizations
#

FILE += /opt/dell/dcc/cctk
/opt/dell/dcc/cctk: bsdtar
	@curl 'https://dl.dell.com/FOLDER12703333M/1/command-configure-5.1.0-23.el9.x86_64.tar.gz?uid=9aa9c676-c797-466f-92a0-b5cf9f684fa1&fn=command-configure-5.1.0-23.el9.x86_64.tar.gz' \
	  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
	  -H 'accept-language: en-US,en;q=0.9,ru;q=0.8,uk;q=0.7' \
	  -b 'akGD=%7B%22country%22%3A%22US%22%2C%22region%22%3A%22NJ%22%7D; signupemail-modal-visited=1; d_vi=0b422417614c0000c23f8868c10100000ba90300; txUid=Co+qLmlKSxVev9JqCAQTAg==; OptanonAlertBoxClosed=2025-12-23T07:56:27.812Z; di_c=eyJhbGciOiJSUzI1NiIsImtpZCI6InN0LTE1NDYzMDA4MDAiLCJ0eXAiOiJKV1QifQ.eyJQcm9maWxlSWQiOiI0YmQzN2Q4OS1lMGZjLTRjOGItYmExZS01YTY5M2YxN2M3NjkiLCJEZXZpY2VJZCI6ImFkZWZiNmM0OTYyZTg4Y2Q2MTg1MzUwOWM1M2E3N2E3ZTYyMmY5MTlkMGI1Yzk0YTM1YzdkMjNkNDg1N2EyMmYiLCJNRkFUeXBlIjoiRW1haWxfT3RwIiwianRpIjoiZDU0NDk5M2MtYTExMi00YTVhLTg3ZTEtNzNjNDIzNDcxN2QwIiwiaWF0IjoxNzY2NDc3NzA3LCJuYmYiOjE3NjY0Nzc3MDcsImV4cCI6MTc2OTA2OTcwNywiaXNzIjoiaHR0cDovL3d3dy5kZWxsLmNvbS9pZGVudGl0eSIsImF1ZCI6Ind3dy5kZWxsLmNvbSJ9.kaizyzjsI-jtZcPgOvcXv-ksp_Yp0_JN8jIVd5H8JkiOOtermQfmrOYS7GeNmrEgOEe-KZGDq0e8zoRGIxUHmy7bfXcvJivFAabiBKF21SRo6Et4qrSvxJQr-xFVm9zzrBE1cr_O_yN0mspxDaYwrLQHIp9mgrOL5BvYG44KFoZdcUdG-zCiTDhNnnDST77ZsxuxsMuGJ0UdEUYYf4Vl0dOWwuBfKy57OPHmB6UHvJi-_BBABipdcT9r3Ah--k3WE3p_a7lmk1vp49iZnPmuRDP2G3bh-BhTrLybxioXTqIWvY5krc7FwEaN7pqsIBccISjj82NT-BIK4vHneNFCVQ; um_g_uc=false; dc-ctxt=c=US&ia=0&l=en&sdn=work&uh=44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a&ut=1768553929855; lwp=c=us&l=en&s=bsd&cs=04; DellCEMSession=8411A2540BA7FCAD6A211FAE57A3DEB8; cidlid=%3A%3A; s_cc=true; dell_cmp_consent={"s":0,"m":0,"e":1}; TS013e9407=01765abcd14030bfb7891f21a2d2c870de3bba39bb8c6f539efb655e2af73bdb15b6affddb914bc8a7b81384577c38605b60b4ae8f; eSupId=SID=f7bb0471-9faf-41e9-8b35-0643a9608b94&apc=command-configure&AT=; OLRProduct=OLRProduct=|command-configure; s_c49=c%3Dus%26l%3Den%26s%3Dbsd%26cs%3D04; v36=pc%3Adell%20command%20configure%20download; s_sq=%5B%5BB%5D%5D; bm_ss=ab8e18ef4e; ak_bmsc=79AFC993CCD451058FFF917607AE07DB~000000000000000000000000000000~YAAQUQwDF3Zi7tebAQAAKx+53h4kIo3fCb5j64mFvCUYAoTU4fsMQfxv0MeTM8noqH98CenGPW67cavW0nYwFJrhKd5ccX1K+JJkoW3Kr9xiJDzQ6KVGiBpddRtx16rCFnKAUF4kHFcuhoHGHoe1IT04SlRh2pG0ucEyZ9831ROTnItlOdMlJLuQiIOUU9biUu65Cyriu64bHdbtCBW6zjDY1p3r+LNF5f5OnqD88WM1rHqkZYbC8x0SHy6byMk4Zi+XMoWw4hQ5fPJ31VrYoBc/5FPZ/EBZ2yZNE+KWo8+faQ8TJkXbl1SekwwM+PCftI1gaPprb/+p4J2WxYdwMtyxUJQwrsYAq0cLR410s30z9uemTimvyBT3QrQYnaSJdNDAHs4cViciqs4=; AMCV_4DD80861515CAB990A490D45%40AdobeOrg=179643557%7CMCIDTS%7C20475%7CMCMID%7C56408787455598005911888581142698341391%7CMCAID%7CNONE%7CvVersion%7C5.5.0; gpv_pn=us%7Cen%7Cbsd%7C04%7Cesupport-home%7Cdriversdetails%7Cindex; s_vnc365=1800504233495%26vn%3D6; s_ivc=true; _abck=B60FC2B7B150C33A78A2DB178F71836F~-1~YAAQUQwDF0xl7tebAQAAeiS53g+cA4M/CQncTVU73jQfhXao07Tx1HROYwlt+Jk13L89DLVarJ28/67mGhZu9YuvagajIYigzvRY9YHaU1ycTvCLiAxqWSPrRFFOXgGQuXmV7qIv1pb1/VXYlk7dC4LrPcSLKEPxw+5JliMNyeO5+orEB20BjoUAk8YV6PG8HDEYTWMOWWPC3EJFP+vNujevhTNwWdeAzK+OmYhKzrQbEvIDkIahf+UBH9T3MmakilgXR8N8YqebsES3eo2nzQ+UjbnUW3SOxe8eUzei+GxbsyJIly8TgYKxSzAQ5THadCtr1wmnlSKChp1FCsnM51FpypTw8I04DIDlQERWpwq5DdNbO4wTi0ri0hvw+mJg/f9MHdtGm8ec8iePGcJGl85dm9QzDmR2URRLeGwF9/gYEkz3YmqVOP43bhFS5TXeXEkRMnTszgRGb6ZaZ/8u7ZhX3jy4R+djxyFOzNu5OhjTLHgl6DXTy+0jGAZev92yaWv+OTb2H269DWp0l/UJT5U9EanpyOTsb7/jWZMWyTajtGZ+kYlS0q+EuS7fDCavKz66/Hv8Ol9hFbKWFiQEcKA//rvKrMG1ET6CHsX1IzzTYrm4iKZs1EeAGk32IunaA7R5xLVqvP0ZRyQVkE4VemWH7ksSPSHhyYTRMVa0q7CyIZ7cqdpS9BBvNu61YuQIX2Ee8X/VwsCkKq0CkKovjGidDUwryw9xWFCuLuur34tgsG9cmGSERK3D1sExnAPYSGcd5bw4q+BmcBoaSkYQsk/y25VL/enJwV1XrdrZbQNRKqKBgEjYdKy39FrxKgadLYdMS9WfA/em6xadi6BBPWFrHswJQ8ohs+IECGVZJLylaoyMSvrxTvSc76uk62FoXV5vkN26Hr/0kUEbKDQB8KF+9mwt76Mpt6mMv0KNreQNRxVB+GtpzZpxEenwlWUlaP7GBnH92RpMohEtf8GpUXIjC4YceVQJxG3gdjEZZjdW/NEDrdKddDZXSxGJl1e6kQBup5Z/mLk0NN3oNs8BcptWvEbkbvoVWI81uF0g+MKp58AR~-1~-1~-1~AAQAAAAF%2f%2f%2f%2f%2f1ImUz%2fwqsgbXZDlBZfwfMU+MT1H3uGfdyO4DfaTM6aKVTXtgje4VRFqprHaVpNP3LaJxofZ9qUVVPp062q0sa2bBSYbetRPpdyO5mHgOKAGKAk9tG6waqbhLXW6O1FvU3b5cFtTq4ujyci9bUSA04H%2fDWq7uQ%2f6l2%2fEohLdxRGB3SXZw3HrSsVtKWWoxYBer+jl7jPIW3KVCrvl7Wu5DxxZ5mI7Ap49HpWabpZh8+x2TWY%3d~-1; bm_mi=F6B30F24BFCFFD7D318C8DF4A3A553FF~YAAQ5cgwF0Gmc9CbAQAAAJ673h4nCKB3bVrBqBsl/w5HFGQhWxYPnaMVlJpmigsTmlY7Lg2QGTz/tahw991Jk/hHXzpQtNDA6CE2sVsMahTbQ/hqRjAeVNlKVxjQI4huD9ERRCGVkZy0OvKZQysWHx4rnGcd67vR7V7A75rDgjAwF0aqrHQcvgb/5oZiaLaaPQ3j5mXaQHOwDUceuiRwJLL9p9xDuheHC2d0DuXYGZf+KltRdAQIsDfUXy4dWq7SfnqxF+EW3A8701SUDTRephT/MeyHbaUKgBrLZc2Zj67nzMeMd5IF8bJnQWhVQok8CXMnDTle20sgA4csI70xZgfji6ZOxk3LykjAqOg9IGs2NEmL~1; bm_s=YAAQ5cgwF0Kmc9CbAQAAAJ673gSCUh38IPOynGMi6ZfJa4hmHRAsUiWGPpnYvJumSqOoTeXDDWoQWpxLbFx9hYpSWs82DDouTD3Aff8Tf8336+lwksh46AoJeWa8QD7LLxRANz49Ij+W2P8Y2638UHF2jQiaYSRbukmYxqFtndHZAblPaq7ETeEl3hYSqdkfj3g+pIWcNf5jcB7TlHEsKtFe1w4ddg9bSEbwSdKboWp3lK5oHmsI543XvIVxgNXc9ptCXy1b5WUP80Mz93H4W8/7G6NTgKpWGYWiXfMC4v3Qt7moTn2DhUmKMiJyCQma1RLBpeWBGkxq7a6QQF56HMNlbcZsNb9dJrDotWXVyj9gt3TIG7IvR1y//DfmIc5NKjhKSZRsCZ8Es4NYSSKqoU5u8eA/qv5HQ+rFpdnINRFWwxfO88gGOQVQAKRAcxz3UHiVHH8IHblSbgdVVFnvpnoRSkOV/ZRt+GOMnnQxRHQFih6r/WAVWe2201RvzbzYWGrocTpDsl1MUtiEtlUgdn6iJnCtV3/3SGa6Fn8u/4LTLBL/LndROZbmghN72Syhdw==; bm_so=D5A8ECCEE321ABA79EF2BE62618038404A38F3255C82B34E246052263C171EC6~YAAQ5cgwF0Omc9CbAQAAAJ673gbMdmsD2Y1I5felqBkOiEXdiIvsHCHvXgw1b6+sgBNqvQ2vhWyIupTt5nfK2LeLPZrLWK78wIrcbz3wPAZ+imIyxTeGHvdV5iLUTBSPT0GF+IrrrmS9xGZGX8Mc0Z1zL9kvk1I0eTcxt2UbC/poHVgsqNPZfr0O9i82/bO4oy5W7Tg/JMM5itD97ALYkMJ5SXhuMZ77RWilVnY+1AFjTQY7I8u2pY4NC8zKED9VkJjgYbS9RvqGVNPpVrPTz08ZA1BdyO9qGcskcFDm4XMaV4m3CZSB/amL91E+fob51TdYWZQjXfAeyRIeGVJZL+5kP22wkbuU+4cjdsbqfsg7ao0Mgwldu1QeqhQGcCQHPVGShza2a8x6JmfZ5lsSyp6xDti7kL8oW7pCYz921TOYhm4CnjrLZtilZJ5TFs6J3AGCv04KnvuxBiIdUw==; bm_sz=EEE37F39D8131EC0D171B3A36AD93BD3~YAAQ5cgwF0Wmc9CbAQAAAJ673h7xLTRmHIq1rGpfIRpny72IOSMV5y0Fz244Ybaz+jv6ae/PtbvrEkdsRpKt8X6PoNAF3nGZqcwo6bdh0TL1LV9cOs5hS+SrMGFLbHXx5s7xPzGOlq7GF2v/xblZ9g0W3K5GWduAyFfdDQ/EA7zX+8lO+3pOz3b+GHE2Ssul/WdwMStBi2bNhr1O38bqTd6s1kJ5V6Hivg1APrsH5oxndOao900bXVrsN7uVAFDQ5NhrU03lrD+z/bUqM86G2IK9Ej2v4FXT5Aybosv8yk7SOgLGr24UbM7Em5YeD1INPM3RYyAL7pLjve/JS3ajfPG0nJ90QVUZ9PVV8WnnvFjdUA1yCS/lhbD/5N/ylk+EhlOpgbFwwIhKvHS/st6H3Jna4Ttk~4600882~4605490; OptanonConsent=isGpcEnabled=1&datestamp=Tue+Jan+20+2026+23%3A06%3A36+GMT-0500+(Eastern+Standard+Time)&version=202512.1.0&browserGpcFlag=1&isIABGlobal=false&consentId=56e79cce-59f2-4ae3-9242-db5d3313b218&interactionCount=2&isAnonUser=1&intType=2&hosts=&landingPath=NotLandingPage&groups=C0001%3A1%2CC0005%3A0%2CC0008%3A0%2CC0012%3A0%2CC0009%3A0&geolocation=%3B&AwaitingReconsent=false; s_ips=1467; s_tp=2517; s_ppv=us%257Cen%257Cbsd%257C04%257Cesupport-home%257Cdriversdetails%257Cindex%2C58%2C58%2C58%2C1467%2C1%2C1; bm_sv=71B0AFEA4B00EBBC32CCBBEB22CB2887~YAAQ5cgwF3Soc9CbAQAAv6O73h7woWX7nWyJz13EcD6R7KuGHw7F8d+FWWACUf41ggulfG8ZBQLds+ykybZTV6AwMc3+71zx9bn1Mpi40MjhxtCJqsnsd4KppOwmcqO9afZHDc+UTTEDBHVCTao5Q9g5B3UjDEj66w33Sfl+UqanFCMHBZv90XW5ySg6Jj2VwkzwpUKhxTuOKbzrOD2tdiKekaYo55c7hFU+dN+k+mRIzDIIOVamWAOkct2FWFc=~1' \
	  -H 'dnt: 1' \
	  -H 'priority: u=0, i' \
	  -H 'referer: https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=38mg1' \
	  -H 'sec-ch-ua: "Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Linux"' \
	  -H 'sec-fetch-dest: document' \
	  -H 'sec-fetch-mode: navigate' \
	  -H 'sec-fetch-site: same-site' \
	  -H 'sec-fetch-user: ?1' \
	  -H 'sec-gpc: 1' \
	  -H 'upgrade-insecure-requests: 1' \
	  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36' \
	| bsdtar -mxv -f - -C /tmp
	-@sudo rpm -ivh /tmp/command-configure*.rpm /tmp/srvadmin-hapi*.rpm
	@rm -fv /tmp/command-configure*.rpm /tmp/srvadmin-hapi*.rpm

########################################################################################################################
#
# Patches
#

# Fix known suspend issues
.PHONY:
fix_dell_deep_sleep: grubby
	@sudo grubby --args='mem_sleep_default=deep' --update-kernel=ALL

# Remove redness from video stream
.PHONY:
fix_dell_camera:
	@sudo dnf install v4l-utils
	@v4l2-ctl -c saturation=42

.PHONY:
install_nvidia_drivers: | /etc/yum.repos.d/rpmfusion-nonfree.repo akmods grubby
	@sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan nvidia-vaapi-driver libva-utils vdpauinfo
	@sudo grubby --update-kernel=ALL --args='rd.driver.blacklist=nouveau modprobe.blacklist=nouveau'
	@sudo akmods --force
	@sudo dracut --force

# Headphones are not automatically recognized by the system
.PHONY:
/etc/modprobe.d/dell.conf: $(DF_DELL_FSROOT)/etc/modprobe.d/dell.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

# Disable bluetooth auto-suspend
.PHONY:
/etc/modprobe.d/btusb.conf: $(DF_DELL_FSROOT)/etc/modprobe.d/btusb.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

.PHONY:
/etc/sysctl.d/97-swappiness.conf: $(DF_DELL_FSROOT)/etc/sysctl.d/97-swappiness.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

PATCH += patch-dell-xps-15-7590
patch-dell-xps-15-7590: fix_dell_deep_sleep \
	fix_dell_camera \
	install_nvidia_drivers \
	/etc/modprobe.d/dell.conf \
	/etc/modprobe.d/btusb.conf \
	/etc/sysctl.d/97-swappiness.conf
