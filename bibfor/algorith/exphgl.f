      SUBROUTINE EXPHGL(NOMRES,TYPSD,MODCYC,PROFNO,INDIRF,MAILSK,
     &                  NBSEC,NUMDIA,NBMODE)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  BUT:
C
C  RESTITUER LES RESULTATS ISSUS D'UN CALCUL CYCLIQUE
C     => RESULTAT COMPOSE DEJA ALLOUE PAR LA
C        ROUTINE APPELLANTE
C
C  DONNEES DU PROFCHNO DEJA CONSTITUE ET DE LA TABLE INDIRECTION
C  DES NUMEROS EQUATIONS CORRESPONDANTES (COLLECTION NUMEROTEE
C  POINTEE PAR LES NUMEROS DE SECTEUR)
C-----------------------------------------------------------------------
C
C NOMRES  /I/: NOM UT DU CONCEPT RESULTAT A REMPLIR
C MODCYC  /I/: NOM UT DU RESULTAT ISSU DU CALCUL CYCLIQUE
C PROFNO  /I/: NOM K19 DU PROFIL CHAMNO DEJA CONSTITUE
C INDIRF  /I/: NOM K24 DE LA FAMILLE DES INDIRECTIONS
C MAILSK  /I/: NOM K8 DU MAILLAGE SKELETTE
C TYPSD   /I/: NOM DU TYPE DE STRUCTURE DE DONNEES RESULTAT
C NBSEC   /I/: NBRE DE SECTEUR
C NUMDIA  /I/: NUMERO DU DIAMETRE
C
C
C
C
C
      INCLUDE 'jeveux.h'
      CHARACTER*8   NOMRES,MODCYC,MAILSK,K8B,MODCYS
      CHARACTER*16  DEPL,TYPSD
      CHARACTER*19  CHAMVA,PROFNO, CHAMNO
      CHARACTER*24  INDIRF,CREFE(2),
     &               NOMCHC, PFCHNO,
     &              NOMCHS
      REAL*8        DEPI,R8DEPI,GENEK,BETA
      INTEGER       NBMODE,IBID,IRET,NEQSEC,LTTSC,LLFREQ,
     &              LTVECO,LDFREQ,LDKGE,LDMGE,
     &              LDOM2,LDOMO,NBNOT,NBCMP,LLCHAM,NBSEC,NEQ,
     &              IRES2,NUMDIA,LTVESI
      INTEGER      IARG
C
C-----------------------------------------------------------------------
C
      DATA DEPL   /'DEPL            '/
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      DEPI = R8DEPI()
C
C-----REMPLISSAGE DU CREFE POUR CREATION CHAMNO-------------------------
C
      CREFE(1) = MAILSK
      CREFE(2) = PROFNO
C
C-----RECUPERATION DU NOMBRE DE DDL PHYSIQUES DU SECTEUR----------------
C
      CALL RSEXCH(MODCYC,'DEPL',1,CHAMNO,IER)
      CALL DISMOI('F','PROF_CHNO',CHAMNO,'CHAM_NO',IBID,PFCHNO,IRET)

      CALL DISMOI('F','NB_EQUA',PFCHNO,'PROF_CHNO',NEQSEC,K8B,IRET)
C     -- QUESTION "POURRIE" :
      CALL DISMOI('F','NOM_GD ',PFCHNO,'PROF_CHNO',IBID,K8B,IRET)
      CALL DISMOI('F','NB_CMP_MAX',K8B,'GRANDEUR',NBCMP,K8B,IRET)
C
C-----RECUPERATION DU NOMBRE DE DDL PHYSIQUES GLOBAUX-------------------
C
      CALL JELIRA(PROFNO//'.DEEQ','LONMAX',NEQ,K8B)
      NEQ = NEQ / 2
C
C-----RECUPERATION DES FREQUENCES---------------------------------------
C
      IF ((TYPSD(1:9).EQ.'MODE_MECA').OR.
     &     (TYPSD(1:4).EQ.'BASE')) THEN
        CALL RSLIPA(MODCYC,'FREQ','&&EXPHGL.LIR8',LLFREQ,N1)
      ELSE
        CALL RSLIPA(MODCYC,'INST','&&EXPHGL.LIR8',LLFREQ,N1)
      ENDIF
C
C-----ALLOCATION DES VECTEURS DE TRAVAIL--------------------------------
C
      CALL WKVECT('&&EXPHGL.VEC.REEL' ,'V V R',NEQSEC,LTVECO)
C
C-----CALCUL DU TETA DE CHAQUE SECTEUR----------------------------------
C
      CALL WKVECT('&&EXPHGL.TETA_SECTEUR','V V R',NBSEC,LTTSC)
      DO 8 I=1,NBSEC
        ZR(LTTSC+I-1) = DEPI*(I-1) / NBSEC
 8    CONTINUE
C
C-----RECUPERATION DE L'INDIRECTION SQUELETTE---------------------------
C
      CALL JEVEUO(MAILSK//'.INV.SKELETON','L',LLINSK)
      CALL DISMOI('F','NB_NO_MAILLA',MAILSK,'MAILLAGE',NBNOT,K8B,IRET)
C
C***********************************************************************
C
      CALL GETVID('CYCLIQUE','RESULTAT2',1,IARG,1,MODCYS,IRES2)

      ICOMP = 0
C
C  CALCUL DU DEPHASAGE INTER-SECTEUR
C
      BETA  = NUMDIA*(DEPI/NBSEC)
C
C  BOUCLE SUR LES MODES PROPRES DU DIAMETRE COURANT
C
      DO 15 I=1,NBMODE
        ICOMP = ICOMP + 1
        CALL RSEXCH ( MODCYC, 'DEPL', I, NOMCHC, IRET )
        CALL JEVEUO ( NOMCHC(1:19)//'.VALE', 'L', LTVECO )
        IF (IRES2.NE.0) THEN
          CALL RSEXCH ( MODCYS, 'DEPL', I, NOMCHS, IRET )
          CALL JEVEUO ( NOMCHS(1:19)//'.VALE', 'L', LTVESI )
        ENDIF
C

C***********************************************************************
C
        CALL RSEXCH(NOMRES,DEPL,I,CHAMVA,IRET)
        CALL VTCREA(CHAMVA,CREFE,'G','R',NEQ)
        CALL RSNOCH(NOMRES,DEPL,I,' ')
        CALL JEVEUO(CHAMVA//'.VALE','E',LLCHAM)
C
C  COMMUN POUR MODE_MECA ET BASE_MODALE
C
        IF ((TYPSD(1:9).EQ.'MODE_MECA')) THEN
          CALL RSADPA(NOMRES,'E',1,'FREQ',I,0,LDFREQ,K8B)
          CALL RSADPA(NOMRES,'E',1,'RIGI_GENE',I,0,LDKGE ,K8B)
          CALL RSADPA(NOMRES,'E',1,'MASS_GENE',I,0,LDMGE ,K8B)
          CALL RSADPA(NOMRES,'E',1,'OMEGA2'   ,I,0,LDOM2 ,K8B)
          CALL RSADPA(NOMRES,'E',1,'NUME_MODE',I,0,LDOMO ,K8B)
          GENEK = (ZR(LLFREQ+ICOMP-1)*DEPI)**2
          ZR(LDFREQ) = ZR(LLFREQ+ICOMP-1)
          ZR(LDKGE)  = GENEK
          ZR(LDMGE)  = 1.D0
          ZR(LDOM2)  = GENEK
          ZI(LDOMO)  = I
C
C  SPECIFIQUE A BASE_MODALE
C
          CALL RSADPA(NOMRES,'E',1,'TYPE_DEFO',I,0,LDTYD,K8B)
          ZK16(LDTYD) = 'PROPRE          '
        ELSE
          CALL RSADPA (NOMRES,'E',1,'INST',I,0,LDFREQ,K8B)
          ZR(LDFREQ) = ZR(LLFREQ+ICOMP-1)
        ENDIF
C
C  BOUCLE SUR LES SECTEURS
C
        DO 20 K=1,NBSEC
          CALL JEVEUO(JEXNUM(INDIRF,K),'L',LTINDS)
          CALL JELIRA(JEXNUM(INDIRF,K),'LONMAX',NDDCOU,K8B)
          NDDCOU = NDDCOU/2
          DO 40 J=1,NDDCOU
            IEQI = ZI(LTINDS+(J-1)*2)
            IEQF = ZI(LTINDS+(J-1)*2+1)
            IF (IRES2.NE.0) THEN
              ZR(LLCHAM+IEQF-1) = SIN((K-1)*BETA)*ZR(LTVECO+IEQI-1)
     &                          +COS((K-1)*BETA)*ZR(LTVESI+IEQI-1)
            ELSE
              ZR(LLCHAM+IEQF-1) = ZR(LTVECO+IEQI-1)
            ENDIF
 40       CONTINUE
 20     CONTINUE
C
C  PRISE EN COMPTE ROTATION SUR CHAQUE SECTEUR
C
        CALL ROTCHM(PROFNO,ZR(LLCHAM),ZR(LTTSC),NBSEC,ZI(LLINSK),
     +              NBNOT,NBCMP,3)
C
        CALL JELIBE ( NOMCHC(1:19)//'.VALE' )
        IF (IRES2.NE.0) THEN
          CALL JELIBE ( NOMCHS(1:19)//'.VALE' )
        ENDIF
 15   CONTINUE
C
      CALL JEDETR ( '&&EXPHGL.VEC.REEL'    )
      CALL JEDETR ( '&&EXPHGL.ORDRE.FREQ'  )
      CALL JEDETR ( '&&EXPHGL.TETA_SECTEUR')
      CALL JEDETR ( '&&EXPHGL.TETGD'       )
      CALL JEDETR ( '&&EXPHGL.LIR8'       )
C
      CALL JEDEMA()
      END
