# $NetBSD$

PKGNAME=		zabbix-agent-${VER}
VER=			3.0.10
DISTNAME=		zabbix-${VER}
CATEGORIES=		net
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE:=zabbix/}
EXTRACT_SUFX=	.tar.gz

MAINTAINER=		pkgsrc@erigones.com
HOMEPAGE=		http://www.zabbix.com/
COMMENT=		Zabbix monitoring agent
LICENSE=		gnu-gpl-v2

GNU_CONFIGURE=	YES
MAKE_JOBS_SAFE=	no

CONFIGURE_ARGS+=	--sysconfdir=${PKG_SYSCONFDIR:Q}
CONFIGURE_ARGS+=	--enable-agent
CONFIGURE_ARGS+=	--disable-server
CONFIGURE_ARGS+=	--with-openssl=${PREFIX}

PKG_SYSCONFSUBDIR=	zabbix
CONF_FILES=		${PKG_SYSCONFDIR}/zabbix_agentd.conf.example \
					${PKG_SYSCONFDIR}/zabbix_agentd.conf
RCD_SCRIPTS=	zabbix_agentd
SMF_NAME=		zabbix-agent

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
	mv -f ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_agentd.conf ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_agentd.conf.example
	echo 'UserParameter=smf.maintenance,/usr/bin/svcs -x | grep -c svc:/' >> ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_agentd.conf.example
	echo 'UserParameter=smf.status[*],/usr/bin/svcs -Ho state $$1 2>/dev/null || echo ZBX_NOTSUPPORTED' >> ${DESTDIR}${PKG_SYSCONFDIR}/zabbix_agentd.conf.example

.include "../../converters/libiconv/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
