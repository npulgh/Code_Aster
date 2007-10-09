      SUBROUTINE XREACG ( MODELE,NOMA,DEFICO,RESOCO)
      IMPLICIT   NONE
      CHARACTER*8         MODELE,NOMA
      CHARACTER*24        DEFICO,RESOCO
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/10/2007   AUTEUR NISTOR I.NISTOR 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C     BUT: CREER ET REACTUALISER LA GEOMETRIE DES FACETTES DE CONTACT 
C          POUR LE TRAITEMENT EN GRANDS GLISSEMENTS AVEC X-FEM  
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C     IN:
C         NOMO : NOM DE L'OBJET MOD�LE
C         NOMA : NOM DU MAILLAGE
C         DEFICO : SD POUR LA DEFINITION DE CONTACT
C         RESOCO : SD POUR LA RESOLUTION DE CONTACT
C
C         
C ----------------------------------------------------------------------
C
C     FONCTIONS EXTERNES:
C     -------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32     JEXNUM, JEXNOM, JEXATR, JEXR8
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C     VARIABLES LOCALES:
C     ------------------------------------------------------------------
      INTEGER       JNOMA,JNFIS,NFIS,IFIS,JMOFIS,NDIM,JLSN,NBEC
      INTEGER       IAVALI,IAVALF,IAREFE,IBID,IAVALD,IADESC,IGD
      INTEGER       IAPRNO,INO,NBNO,IERD,NEC,IVAL,NCMP,ICOMPT,ICMP
      INTEGER       JDIM
      REAL*8        H, RDEPLA,HDEPLA(3)
      CHARACTER*8   KBID
      CHARACTER*19  CHGEOM, GEOMFI,DEPLA,CHS
      CHARACTER*24  NOMNU
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      CALL JEVEUO(DEFICO(1:16)//'.NDIMCO','L',JDIM)
      NDIM = ZI(JDIM)

C     RECUPERATION DE LA GEOMETRIE

      CHGEOM = NOMA(1:8)//'.COORDO'
      DEPLA = RESOCO(1:14)//'.DEPG'

C     ON CREE LA SD GEOMFI

      GEOMFI='&&XREACG.GEOMFI'

C     RECUPERATION DU CHAMPS DES VALEURS DE LA LSN
      CHS='&&XREACG.CHS'
      CALL CNOCNS(MODELE//'.LNNO','V',CHS)
      CALL JEVEUO(CHS//'.CNSV','L',JLSN)
 
C     -- ON RECOPIE LE CHAMP DES COORD POUR CREER LE NOUVEAU:
      CALL COPISD('CHAMP_GD','V',CHGEOM,GEOMFI)

C     I. REACTUALISATION DE LA GEOMETRIE DES NOEUDS DU MAILLAGE 
C     (on se sert pas encore dans l'analyse grands glissements 
C      mais �a marche!)

      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,KBID,IERD)

      CALL JEVEUO (CHGEOM//'.VALE','L',IAVALI)
      CALL JEVEUO (GEOMFI//'.VALE','E',IAVALF)

      CALL JEVEUO(DEPLA//'.REFE','L',IAREFE)
      NOMNU = ZK24(IAREFE-1+2)
 
      CALL JELIRA(DEPLA//'.VALE','TYPE',IBID,KBID)
      IF (KBID(1:1).NE.'R')     CALL U2MESS('F','CALCULEL_9')
      CALL JEVEUO(DEPLA//'.VALE','L',IAVALD)
 
      CALL JEVEUO(DEPLA//'.DESC','L',IADESC)
      IGD = ZI(IADESC-1+1)
C      NUM = ZI(IADESC-1+2)
      NEC = NBEC(IGD)

C      -- ON RECUPERE CE QUI CONCERNE LES NOEUDS DU MAILLAGE:
      CALL JELIRA(JEXNUM(NOMNU(1:19)//'.PRNO',1),'LONMAX',IBID, KBID)
      IF (IBID.EQ.0) CALL U2MESS('F','CATAELEM_14')
      CALL JEVEUO(JEXNUM(NOMNU(1:19)//'.PRNO',1),'L',IAPRNO)
C
      DO 100,INO = 1,NBNO
        CALL LCINVN(NDIM,0.D0,HDEPLA)
C       NCMP : NOMBRE DE CMPS SUR LE NOEUD INO
C       IVAL : ADRESSE DU DEBUT DU NOEUD INO DANS VALE
        IVAL = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+1)
        NCMP = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+2)
 
        IF (NCMP.EQ.0) GO TO 100
 
        IF ((NCMP.EQ.2).OR.(NCMP.EQ.8)) THEN
C       ---NOEUDS CLASSIQUES

          ICOMPT = 0
          DO 110,ICMP = 1,NDIM
            ICOMPT = ICOMPT + 1
            RDEPLA = ZR(IAVALD-1+IVAL-1+ICOMPT)

            ZR(IAVALF-1+3*(INO-1)+ICMP)=
     &               ZR(IAVALI-1+3*(INO-1)+ICMP)+RDEPLA
 110      CONTINUE
        ELSE
C       ---NOEUDS ENRICHIES

          ICOMPT = 0
          IF (ZR(JLSN-1+INO).GT.0) THEN
            H=1.D0
          ELSE
            H=-1.D0
          ENDIF

C       ---CONTRIBUTION DES DDL CLASSIQUES	  
          DO 120,ICMP = 1,NDIM
            ICOMPT = ICOMPT + 1
            HDEPLA(ICMP)=HDEPLA(ICMP)+ZR(IAVALD-1+IVAL-1+ICOMPT)

 120      CONTINUE
C       ---CONTRIBUTIONS DES DDL ENRICHIES H 
          DO 130,ICMP = 1,NDIM
            ICOMPT = ICOMPT + 1
            HDEPLA(ICMP)=HDEPLA(ICMP)+H*ZR(IAVALD-1+IVAL-1+ICOMPT)
 130      CONTINUE 
C        ---MISE A JOURS DES COORDONNEES DU NOEUD 
          DO 140,ICMP = 1,NDIM
            ZR(IAVALF-1+3*(INO-1)+ICMP)=
     &               ZR(IAVALI-1+3*(INO-1)+ICMP)+HDEPLA(ICMP)
 140      CONTINUE
        ENDIF
 100  CONTINUE

      CALL JEDETR('&&XREACG.GEOMFI')
      CALL JEDETR('&&XREACG.CHS')

C     FIN DE REACTUALISATION DE LA GEOMETRIE DES NOEUDS DU MAILLAGE

C---- CALCUL DE LA NOUVELLE GEOMETRIE DES FACETTES DE CONTACT
      CALL XGECFI(MODELE,CHGEOM,DEPLA)

      CALL JEDEMA()
      END
