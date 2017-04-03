# $NetBSD$

PKGNAME=		zabbix-proxy-${VER}
VER=			3.0.8
DISTNAME=		zabbix-${VER}
CATEGORIES=		net
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE:=zabbix/}
EXTRACT_SUFX=	.tar.gz

MAINTAINER=		pkgsrc@erigones.com
HOMEPAGE=		http://www.zabbix.com/
COMMENT=		Zabbix monitoring proxy
LICENSE=		gnu-gpl-v2

GNU_CONFIGURE=	YES
MAKE_JOBS_SAFE=	no

CONFIGURE_ARGS+=	--sysconfdir=${PKG_SYSCONFDIR:Q}
CONFIGURE_ARGS+=	--disable-agent
CONFIGURE_ARGS+=	--disable-server
CONFIGURE_ARGS+=	--enable-proxy
CONFIGURE_ARGS+=	--with-openssl=${PREFIX}
CONFIGURE_ARGS+=	--with-sqlite3=${PREFIX}
CONFIGURE_ARGS+=	--with-libcurl

BUILDLINK_API_DEPENDS.openssl+= openssl>=1.0
BUILDLINK_API_DEPENDS.sqlite3+= sqlite3>=3.9.2
BUILDLINK_API_DEPENDS.curl+= curl>=7.51.0

PKG_SYSCONFSUBDIR=	zabbix
CONF_FILES=		${PKG_SYSCONFDIR}/zabbix_proxy.conf.example \
					${PKG_SYSCONFDIR}/zabbix_proxy.conf
RCD_SCRIPTS=	zabbix_proxy
SMF_NAME=		zabbix-proxy

# ZABBIX user account
ZBXUSER?=			zabbix
ZBXGROUP?=			zabbix
ZBXUID?=			993
ZBXGID?=			993
ZBXHOME?=			${VARBASE}/${ZBXUSER}
ZBXLOGDIR?=			${VARBASE}/log/zabbix
ZBXPIDDIR?=			${VARBASE}/run

OWN_DIRS+=			${ZBXHOME} ${ZBXLOGDIR}
OWN_DIRS_PERMS+=	${ZBXHOME} ${ZBXUSER} ${ZBXGROUP} 0770
OWN_DIRS_PERMS+=	${ZBXLOGDIR} ${ZBXUSER} ${ZBXGROUP} 0770

FILES_SUBST+=		ZBXUSER=${ZBXUSER}
FILES_SUBST+=		ZBXGROUP=${ZBXGROUP}
FILES_SUBST+=		ZBXHOME=${ZBXHOME}
BUILD_DEFS+=		VARBASE ZBXUSER ZBXGROUP ZBXHOME

PKG_GROUPS_VARS+=	ZBXGROUP
PKG_USERS_VARS+=	ZBXUSER

PKG_GROUPS=				${ZBXGROUP}
PKG_USERS=				${ZBXUSER}:${ZBXGROUP}
PKG_HOME.${ZBXUSER}=	${ZBXHOME}
PKG_GECOS.${ZBXUSER}=	Zabbix monitoring pseudo-user
PKG_UID.${ZBXUSER}=		${ZBXUID}
PKG_GID.${ZBXGROUP}=	${ZBXGID}

post-install:
	mv -f ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_proxy.conf ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_proxy.conf.example

.include "../../mk/bsd.pkg.mk"
