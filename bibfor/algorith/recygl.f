      SUBROUTINE RECYGL(NMRESZ,TYPSDZ,MDCYCZ,MAILLZ,PROFNO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2007   AUTEUR PELLET J.PELLET 
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
C***********************************************************************
C    P. RICHARD     DATE 10/02/92
C-----------------------------------------------------------------------
C  BUT:           < RESTITUTION CYCLIQUE GLOBALE >
      IMPLICIT REAL*8 (A-H,O-Z)
C
C   RESTITUTION EN BASE PHYSIQUE DES RESULTATS CYCLIQUE
C    SUR UN MAILLAGE SQUELETTE DE LA STRUCTURE GLOBALE
C
C LE MAILLAGE REQUIS EST UN MAILLAGE AU SENS ASTER PLUS
C UN OBJET MAILLA//'.INV.SKELETON'
C
C-----------------------------------------------------------------------
C
C NMRESZ   /I/: NOM UT DU RESULTAT (TYPSD)
C MDCYCZ   /I/: NOM UT DU MODE_CYCL AMONT
C MAILLA   /I/: NOM UT DU MAILLAGE SQUELETTE SUPPORT
C PROFNO   /I/: NOM K19 DU PROFNO  DU SQUELETTE
C TYPSDZ   /I/: TYPE STRUCTURE DONNE RESULTAT (MODE_MECA,BASE_MODALE)
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C-----  FIN  COMMUNS NORMALISES  JEVEUX  -------------------------------
C
      CHARACTER*6      PGC
      CHARACTER*(*) NMRESZ,MDCYCZ,TYPSDZ,MAILLZ
      CHARACTER*8 NOMRES,MAILLA,MODCYC,BASMOD,TYPINT
      CHARACTER*16 TYPSD
      CHARACTER*19 PROFNO
      CHARACTER*24 INDIRF
      CHARACTER*1 K1BID
C
C-----------------------------------------------------------------------
      DATA PGC /'RECYGL'/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      NOMRES = NMRESZ
      MODCYC = MDCYCZ
      TYPSD  = TYPSDZ
      MAILLA = MAILLZ
C
      INDIRF='&&'//PGC//'.INDIR.SECT'
C
C-----------------ECRITURE DU TITRE-------------------------------------
C
      CALL TITRE
C
C--------------VERIFICATION SUR MAILLAGE SQUELETTE----------------------
C
      CALL JEEXIN(MAILLA//'.INV.SKELETON',IRET)
      IF(IRET.EQ.0) THEN
            CALL U2MESG('F', 'ALGORITH13_8',0,' ',0,0,0,0.D0)
      ENDIF
C
C
C-------------------RECUPERATION DE LA BASE MODALE----------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_REFE','L',LLREF)
C
C-----------------------RECUPERATION DU TYPE INTERFACE------------------
C
C
      CALL JEVEUO(MODCYC//'.CYCL_TYPE','L',LLTYP)
      TYPINT=ZK8(LLTYP)
C
C
C------------------RECUPERATION DU NOMBRE DE SECTEURS-------------------
C
C
      CALL JEVEUO(MODCYC//'.CYCL_NBSC','L',LLNOMS)
      NBSEC=ZI(LLNOMS)
      MDIAPA=INT(NBSEC/2)*INT(1-NBSEC+(2*INT(NBSEC/2)))
C
C-----RECUPERATION NOMBRE MODES PROPRES UTILISES POUR CALCUL CYCLIQUE---
C            ET NOMBRE DE MODES CALCULES PAR DIAMETRE NODAUX
C
      CALL JEVEUO(MODCYC//'.CYCL_DESC','L',LLDESC)
      NBMCAL=ZI(LLDESC+3)
C
C----------DETERMINATION DU NOMBRE DE MODES PHYSIQUE A RESTITUER--------
C
      CALL JEVEUO(MODCYC//'.CYCL_DIAM','L',LLDIA)
      CALL JELIRA(MODCYC//'.CYCL_DIAM','LONMAX',NBDIA,K1BID)
      NBDIA=NBDIA/2
C
      ICOMP=0
      DO 10 I=1,NBDIA
        IDIA=ZI(LLDIA+I-1)
        NBMCAL=ZI(LLDIA+NBDIA+I-1)
        IF(IDIA.EQ.0.OR.IDIA.EQ.MDIAPA) THEN
          ICOMP=ICOMP+NBMCAL
        ELSE
          ICOMP=ICOMP+2*NBMCAL
        ENDIF
 10   CONTINUE
C
      NBMOR=ICOMP
C
C--------------ALLOCATION DU CONCEPT MODE_MECA RESULTAT-----------------
C
      WRITE(6,*)'RECYGL NOMRES: ',NOMRES
      WRITE(6,*)'RECYGL TYPSD: ',TYPSD
      WRITE(6,*)'RECYGL NBMOR: ',NBMOR
      CALL RSCRSD(NOMRES,TYPSD,NBMOR)
C
C-------------------CREATION PROF_CHAMNO ET TABLES INDIRECTION----------
C
      CALL CYNUGL(PROFNO,INDIRF,MODCYC,MAILLA)
C
C------------------------------RESTITUTION -----------------------------
C
C
C
C    CAS CRAIG-BAMPTON ET CRAIG-BAMPTON HARMONIQUE
C
      IF(TYPINT.EQ.'CRAIGB  '.OR.TYPINT.EQ.'CB_HARMO') THEN
        CALL RECBGL(NOMRES,TYPSD,MODCYC,PROFNO,INDIRF,MAILLA)
      ENDIF
C
C
C    CAS MAC NEAL AVEC ET SANS CORRECTION
C
      IF(TYPINT.EQ.'MNEAL   '.OR.TYPINT.EQ.'AUCUN   ') THEN
        CALL REMNGL(NOMRES,TYPSD,MODCYC,PROFNO,INDIRF,MAILLA)
      ENDIF
C
      CALL JEDETR('&&'//PGC//'.INDIR.SECT')
 9999 CONTINUE
      CALL JEDEMA()
      END
