      SUBROUTINE MMVERI(NOMA  ,DEFICO,RESOCO,NEWGEO,SDAPPA,
     &                  NPT   ,JEUX  ,LOCA  ,ENTI  ,ZONE  )
C
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8   NOMA
      CHARACTER*24  DEFICO,RESOCO
      CHARACTER*19  NEWGEO
      CHARACTER*19  SDAPPA
      CHARACTER*24  JEUX,LOCA,ENTI,ZONE
      INTEGER       NPT
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE VERIF)
C
C METHODE VERIF POUR LA FORMULATION CONTINUE
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  NEWGEO : GEOMETRIE ACTUALISEE
C IN  SDAPPA : NOM DE LA SD APPARIEMENT
C IN  JEUX   : NOM DE LA SD STOCKANT LE JEU
C IN  ENTI   : NOM DE LA SD STOCKANT LES NOMS DES ENTITES APPARIEES
C IN  ZONE   : NOM DE LA SD STOCKANT LA ZONE A LAQUELLE APPARTIENT LE
C              POINT
C IN  LOCA   : NUMERO DU NOEUD POUR LE POINT DE CONTACT (-1 SI LE POINT
C              N'EST PAS UN NOEUD ! )
C IN  NPT    : NOMBRE DE POINTS EN MODE VERIF
C
C
C
C
      INTEGER      IFM,NIV
      INTEGER      CFDISI,MMINFI,TYPINT,NDEXFR
      INTEGER      TYPAPP,ENTAPP
      INTEGER      JDECME
      INTEGER      POSMAE,NUMMAE,NUMMAM,POSNOE,POSMAM,NUMNOE
      INTEGER      IZONE,IMAE,IP,IPTM,IPT
      INTEGER      NDIMG,NZOCO
      INTEGER      NPTM,NBMAE,NBPC,NNOMAE,NPT0
      INTEGER      IBID
      REAL*8       GEOMP(3),COORPC(3)
      REAL*8       TAU1M(3),TAU2M(3)
      REAL*8       TAU1(3),TAU2(3)
      REAL*8       NORM(3),NOOR
      REAL*8       KSIPR1,KSIPR2
      REAL*8       R8VIDE,R8PREM
      REAL*8       JEU,DIST
      CHARACTER*8  NOMMAE,NOMMAM,ALIASE
      CHARACTER*16 NOMPT,NOMENT
      LOGICAL      MMINFL,LVERI,LEXFRO
      INTEGER      JJEUX,JLOCA,JENTI,JZONE
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- INITIALISATIONS
C
      POSNOE = 0
      IPT    = 1
C
C --- QUELQUES DIMENSIONS
C
      NZOCO  = CFDISI(DEFICO,'NZOCO' )
      NDIMG  = CFDISI(DEFICO,'NDIM'  )
C
C --- ACCES SD PROVISOIRES
C
      CALL JEVEUO(JEUX  ,'E',JJEUX )
      CALL JEVEUO(LOCA  ,'E',JLOCA )
      CALL JEVEUO(ENTI  ,'E',JENTI )
      CALL JEVEUO(ZONE  ,'E',JZONE )
C
C --- BOUCLE SUR LES ZONES
C
      IP     = 1
      NPT0   = 0
      DO 10 IZONE = 1,NZOCO
C
C ----- OPTIONS SUR LA ZONE DE CONTACT
C
        TYPINT = MMINFI(DEFICO,'INTEGRATION',IZONE )
        LVERI  = MMINFL(DEFICO,'VERIF' ,IZONE )
        NBMAE  = MMINFI(DEFICO,'NBMAE' ,IZONE )
        JDECME = MMINFI(DEFICO,'JDECME',IZONE )
C
C ----- MODE NON-VERIF: ON SAUTE LES POINTS
C
        IF (.NOT.LVERI) THEN
          NBPC   = MMINFI(DEFICO,'NBPC'  ,IZONE )
          IP     = IP + NBPC
          GOTO 25
        ENDIF
C
C ----- BOUCLE SUR LES MAILLES ESCLAVES
C
        DO 20 IMAE = 1,NBMAE
C
C ------- NUMERO ABSOLU DE LA MAILLE ESCLAVE
C
          POSMAE = JDECME + IMAE
          CALL CFNUMM(DEFICO,1     ,POSMAE,NUMMAE)
C
C ------- NOMBRE DE POINTS SUR LA MAILLE ESCLAVE
C
          CALL MMINFM(POSMAE,DEFICO,'NPTM',NPTM  )
C
C ------- INFOS SUR LA MAILLE ESCLAVE
C
          CALL MMELTY(NOMA  ,NUMMAE,ALIASE,NNOMAE,IBID  )
          CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',NUMMAE),NOMMAE)
          CALL MMINFM(POSMAE,DEFICO,'NDEXFR',NDEXFR)
          LEXFRO = (NDEXFR.NE.0)
C
C ------- BOUCLE SUR LES POINTS
C
          DO 30 IPTM = 1,NPTM
C
C --------- INFOS APPARIEMENT
C
            CALL APINFI(SDAPPA,'APPARI_TYPE'     ,IP    ,TYPAPP)
            CALL APINFI(SDAPPA,'APPARI_ENTITE'   ,IP    ,ENTAPP)
            CALL APINFR(SDAPPA,'APPARI_PROJ_KSI1',IP    ,KSIPR1)
            CALL APINFR(SDAPPA,'APPARI_PROJ_KSI2',IP    ,KSIPR2)
            CALL APVECT(SDAPPA,'APPARI_TAU1'     ,IP    ,TAU1M )
            CALL APVECT(SDAPPA,'APPARI_TAU2'     ,IP    ,TAU2M )
C
C --------- COORDONNEES DU POINT DE CONTACT
C
            CALL APCOPT(SDAPPA,IP    ,COORPC)
C
C --------- APPARIEMENT NODAL INTERDIT !
C
            IF (TYPAPP.EQ.1) THEN
              CALL ASSERT(.FALSE.)
            ENDIF
C
C --------- INFO SUR LA MAILLE MAITRE
C
            POSMAM = ENTAPP
            CALL CFNUMM(DEFICO,1     ,POSMAM,NUMMAM)
            CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',NUMMAM),NOMMAM)
C
C --------- POSITION DU NOEUD ESCLAVE SI INTEGRATION AUX NOEUDS
C
            CALL MMPNOE(DEFICO,POSMAE,ALIASE,TYPINT,IPTM  ,
     &                  POSNOE)
C
C --------- NUMERO ABSOLU DU POINT DE CONTACT
C
            CALL MMNUMN(NOMA  ,TYPINT,NUMMAE,NNOMAE,IPTM  ,
     &                  NUMNOE)
C
C --------- COORDONNEES ACTUALISEES DE LA PROJECTION DU PT DE CONTACT
C
            CALL MCOPCO(NOMA  ,NEWGEO,NDIMG ,NUMMAM,KSIPR1,
     &                  KSIPR2,GEOMP )
C
C --------- RE-DEFINITION BASE TANGENTE SUIVANT OPTIONS
C
            CALL MMTANR(NOMA  ,NDIMG ,DEFICO,RESOCO,IZONE ,
     &                  LEXFRO,POSNOE,KSIPR1,KSIPR2,POSMAM,
     &                  NUMMAM,TAU1M ,TAU2M ,TAU1  ,TAU2  )
C
C --------- CALCUL DE LA NORMALE
C
            CALL MMNORM(NDIMG ,TAU1  ,TAU2  ,NORM  ,NOOR  )
            IF (NOOR.LE.R8PREM()) THEN
              CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',NUMMAM),NOMMAM)
              CALL U2MESK('F','CONTACT3_24',1,NOMMAM)
            ENDIF
C
C --------- CALCUL DU JEU ACTUALISE AU POINT DE CONTACT
C
            CALL MMNEWJ(NDIMG ,COORPC,GEOMP ,NORM  ,JEU   )
C
C --------- CALCUL DU JEU FICTIF AU POINT DE CONTACT
C
            CALL CFDIST(DEFICO,'CONTINUE',IZONE ,POSNOE,POSMAE,
     &                  COORPC,DIST      )
C
C --------- NOM DU POINT DE CONTACT
C
            CALL MMNPOI(NOMA  ,NOMMAE,NUMNOE,IPTM  ,NOMPT )
C
C --------- JEU TOTAL + NOM APPARIEMENT
C
            IF (TYPAPP.EQ.2) THEN
              NOMENT = NOMMAM
              JEU    = JEU+DIST
            ELSEIF (TYPAPP.EQ.-1) THEN
              NOMENT = 'EXCLU'
              JEU    = R8VIDE()
            ELSEIF (TYPAPP.EQ.-2) THEN
              NOMENT = 'EXCLU'
              JEU    = R8VIDE()
            ELSEIF (TYPAPP.EQ.-3) THEN
              NOMENT = 'EXCLU'
              JEU    = R8VIDE()
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
C
C --------- SAUVEGARDE
C
            ZR(JJEUX+IPT-1)           = -JEU
            ZI(JLOCA+IPT-1)           = NUMNOE
            ZI(JZONE+IPT-1)           = IZONE
            ZK16(JENTI+2*(IPT-1)+1-1) = NOMPT
            ZK16(JENTI+2*(IPT-1)+2-1) = NOMENT
C
C --------- LIAISON SUIVANTE
C
            IPT    = IPT + 1
            NPT0   = NPT0+ 1
C
C --------- POINT SUIVANT
C
            IP     = IP + 1
C
  30      CONTINUE
  20    CONTINUE
  25    CONTINUE
  10  CONTINUE
C
      CALL ASSERT(NPT0.EQ.NPT)
C
      CALL JEDEMA()
      END
