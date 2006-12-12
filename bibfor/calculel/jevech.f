      SUBROUTINE JEVECH(NMPARZ,LOUEZ,ITAB)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      CHARACTER*(*) NMPARZ,LOUEZ
      CHARACTER*8 NOMPAR
      INTEGER ITAB
C     -----------------------------------------------------------------
C     ENTREES:
C     NOMPAR  : NOM DU PARAMETRE DE L'OPTION
C     LOUEZ   : 'L' OU 'E'  ( LECTURE/ECRITURE )

C     SORTIES:
C     ITAB     : ADRESSE DU CHAMP LOCAL CORRESPONDANT A NOMPAR
C     -----------------------------------------------------------------
      CHARACTER*16 OPTION,NOMTE,NOMTM,PHENO,MODELI
      COMMON /CAKK01/OPTION,NOMTE,NOMTM,PHENO,MODELI

      INTEGER IACHLO,IADSGD,IAMLOC,IAOPDS,IAOPMO,IAOPNO,IAOPPA
      INTEGER ILCHLO,K,KK
      INTEGER IEL,ILMLOC,ILOPMO,IAOPTT
      INTEGER ILOPNO,INDIK8,IPARG,LGCO,NPARIO,LGCATA
      INTEGER NPARIN,IACHII,IACHIK,IACHIX,IACHOI,IACHOK,JCELD,ADIEL
      INTEGER DEBUGR,LONCHL,DECAEL,IADZI,IAZK24

      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      INTEGER        IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII08/IEL
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII07/IACHOI,IACHOK
      INTEGER CAINDZ(512),CAPOIZ
      COMMON /CAII12/CAINDZ,CAPOIZ

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,ETENDU
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*24 VALK(3)
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80

C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------

C DEB -----------------------------------------------------------------
      NOMPAR = NMPARZ

C     -- RECHERCHE DE LA CHAINE NOMPAR AVEC MEMOIRE SUR TOUT 'CALCUL'
      CAPOIZ = CAPOIZ + 1
      IF (CAPOIZ.GT.512) THEN
        IPARG = INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
      ELSE
        IF (ZK8(IAOPPA-1+CAINDZ(CAPOIZ)).EQ.NOMPAR) THEN
          IPARG = CAINDZ(CAPOIZ)
        ELSE
          IPARG = INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
          CAINDZ(CAPOIZ) = IPARG
        END IF
      END IF


      IF (IPARG.EQ.0) THEN
         VALK(1) = NOMPAR
         VALK(2) = OPTION
         CALL U2MESK('E','CALCULEL2_69', 2 ,VALK)
        CALL CONTEX(OPTION,0,' ',' ',0)
      END IF

      IACHLO = ZI(IAWLOC-1+7* (IPARG-1)+1)
      ILCHLO = ZI(IAWLOC-1+7* (IPARG-1)+2)
      LGCATA = ZI(IAWLOC-1+7* (IPARG-1)+4)

      IF (LGCATA.EQ.-1) THEN
         VALK(1) = NOMPAR
         VALK(2) = OPTION
         VALK(3) = NOMTE
         CALL U2MESK('E','CALCULEL2_70', 3 ,VALK)
        CALL CONTEX(OPTION,0,NOMPAR,' ',0)
      END IF


      IF (IACHLO.EQ.-1) THEN
         VALK(1) = NOMPAR
         VALK(2) = OPTION
         VALK(3) = NOMTE
         CALL U2MESK('E','CALCULEL2_71', 3 ,VALK)
        CALL CONTEX(OPTION,0,NOMPAR,' ',0)

      END IF
      IF (IACHLO.EQ.-2) CALL U2MESS('F','CALCULEL2_72')


C     -- CALCUL DE ITAB,LONCHL,DECAEL :
C     ---------------------------------
      CALL CHLOET(IPARG,ETENDU,JCELD)
      IF (ETENDU) THEN
        ADIEL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4+4* (IEL-1)+4)
        DEBUGR = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+8)
        IF (LGCATA.NE.ZI(JCELD-1+ZI(JCELD-1+4+IGR)+3)) CALL U2MESS('F','
     &CALCULEL_13')
        DECAEL = (ADIEL-DEBUGR)
        LONCHL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4+4* (IEL-1)+3)
      ELSE
        DECAEL = (IEL-1)*LGCATA
        LONCHL = LGCATA
      END IF
      ITAB = IACHLO + DECAEL


C     -- ON VERIFIE QUE L'EXTRACTION EST COMPLETE SUR L'ELEMENT:
C     ----------------------------------------------------------
      IF (ILCHLO.NE.-1) THEN
        DO 10,K = 1,LONCHL
          IF (.NOT.ZL(ILCHLO+DECAEL-1+K)) THEN


            WRITE (6,*) 'ERREUR JEVECH ZL :',NOMPAR,
     &        (ZL(ILCHLO+DECAEL-1+KK),KK=1,LONCHL)


             VALK(1) = NOMPAR
             VALK(2) = OPTION
             VALK(3) = NOMTE
             CALL U2MESK('E','CALCULEL2_73', 3 ,VALK)

            CALL TECAEL(IADZI,IAZK24)
            WRITE (6,*) 'MAILLE: ',ZK24(IAZK24-1+3)
            WRITE (6,*) '1ERE COMPOSANTE ABSENTE: ','A FAIRE ???'
            CALL CONTEX(OPTION,0,NOMPAR,' ',0)
          END IF
   10   CONTINUE
      END IF

      END
