      SUBROUTINE CFMXSD(NOMA  ,NOMO  ,NUMEDD,FONACT,DEFICO,
     &                  RESOCO,LIGRCF,LIGRXF)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 20/06/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*8  NOMA,NOMO
      CHARACTER*24 NUMEDD
      CHARACTER*19 LIGRCF,LIGRXF
      INTEGER      FONACT(*)     
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES)
C
C CREATION DES SDS DE RESOLUTION DU CONTACT (RESOCO)
C      
C ----------------------------------------------------------------------
C
C
C IN  NUMEDD : NUME_DDL DE LA MATRICE TANGENTE GLOBALE
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  LIGRCF : NOM DU LIGREL TARDIF POUR ELEMENTS DE CONTACT CONTINUE
C IN  LIGRXF : NOM DU LIGREL TARDIF POUR ELEMENTS DE CONTACT XFEM GG
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      CFMMVD,ZDIAG,ZBOUC,ZTACO
      INTEGER      CFDISI,NZOCO
      INTEGER      IFM,NIV
      LOGICAL      CFDISL,LCTCD,LCTCC,LXFCM,LMAIL,LALLV
      CHARACTER*24 DIAGI,DIAGT,MBOUCL,TABCOF
      INTEGER      JDIAGI,JDIAGT,JMBOUC,JTABCO
      CHARACTER*24 NOSDCO
      INTEGER      JNOSDC
      CHARACTER*14 NUMEDF
      CHARACTER*24 CRNUDD,MAXDEP
      INTEGER      JCRNUD,JMAXDE
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)    
C
C --- FONCTIONNALITES ACTIVEES
C
      LMAIL  = CFDISL(DEFICO,'FORMUL_MAILLEE')
      LXFCM  = CFDISL(DEFICO,'FORMUL_XFEM')
      LCTCC  = CFDISL(DEFICO,'FORMUL_CONTINUE')
      LCTCD  = CFDISL(DEFICO,'FORMUL_DISCRETE')
      LALLV  = CFDISL(DEFICO,'ALL_VERIF')
C
C --- INITIALISATIONS
C
      ZDIAG  = CFMMVD('ZDIAG')
      ZBOUC  = CFMMVD('ZBOUC')
      ZTACO  = CFMMVD('ZTACO')
C --- NUME_DDL MATRICE FROTTEMENT      
      NUMEDF = '&&CFMXSD.NUMDF'
      NZOCO  = CFDISI(DEFICO,'NZOCO')     
C
C --- CREATION DES SD RESULTATS: VALE_CONT ET PERCUSSIONS
C
      CALL CFMXR0(DEFICO,RESOCO,NOMA  )
C
C --- CREATION DE LA SD APPARIEMENT
C
      IF (LMAIL) THEN
        CALL CFMMAP(NOMA  ,DEFICO,RESOCO)
      ENDIF
C
C --- CREATION DES COMPTEURS DE BOUCLE
C
      MBOUCL = RESOCO(1:14)//'.MBOUCL'
      CALL WKVECT(MBOUCL,'V V I'  ,ZBOUC,JMBOUC)
C
C --- STOCKAGE NOM DES SD DE DONNES TYPE LIGREL ET CARTE
C
      NOSDCO = RESOCO(1:14)//'.NOSDCO'
      CALL WKVECT(NOSDCO,'V V K24',5,JNOSDC)
      ZK24(JNOSDC+1-1) = NUMEDF
      ZK24(JNOSDC+2-1) = LIGRCF
      ZK24(JNOSDC+3-1) = LIGRXF
C
C --- VECTEURS DE DIAGNOSTIC
C
      DIAGI  = RESOCO(1:14)//'.DIAG.ITER'
      CALL WKVECT(DIAGI,'V V I',ZDIAG,JDIAGI)
      DIAGT  = RESOCO(1:14)//'.DIAG.TIME'
      CALL WKVECT(DIAGT,'V V R',ZDIAG,JDIAGT)
C
C --- TABLEAU DES COEFFICIENTS
C
      TABCOF = RESOCO(1:14)//'.TABL.COEF'
      CALL WKVECT(TABCOF,'V V R',NZOCO*ZTACO,JTABCO)
C
C --- INITIALISE LES COEFFICIENTS VARIABLES 
C
      CALL CFMMCI(DEFICO,RESOCO) 
C
C --- LOGICAL POUR DECIDER DE REFAIRE LE NUME_DDL OU NON
C
      IF (LCTCC) THEN
        CRNUDD = RESOCO(1:14)//'.NUDD'   
        CALL WKVECT(CRNUDD,'V V L',1,JCRNUD)  
        IF (LALLV) THEN
          ZL(JCRNUD) = .FALSE.
        ELSE
          ZL(JCRNUD) = .TRUE.
        ENDIF
      ENDIF
C
C --- PARAMETRE POUR LA REACTUALISATION AUTOMATIQUE
C
      MAXDEP = RESOCO(1:14)//'.MAXD'
      CALL WKVECT(MAXDEP,'V V R',1,JMAXDE)
      ZR(JMAXDE) = -1.D0      
C
C --- MODE ALL VERIF
C        
      IF (LALLV) THEN
        GOTO 99
      ENDIF
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> CREATION SD DE RESOLUTION' 
      ENDIF       
C
C --- CREATION DES SD POUR METHODES MAILLEES
C
      IF (LMAIL) THEN
        CALL CFMMMA(DEFICO,RESOCO)
      ENDIF    
C      
C --- CONTACT DISCRET
C    
      IF (LCTCD) THEN
        CALL CFCRSD(NOMA  ,NUMEDD,DEFICO,RESOCO)  
      ENDIF
C
C --- CONTACT CONTINU
C 
      IF (LCTCC) THEN
        CALL CFMXME(NOMA  ,NUMEDD,DEFICO,RESOCO) 
      ENDIF
C
C --- CONTACT XFEM
C 
      IF (LXFCM) THEN
        CALL XXMXME(NOMA  ,NOMO  ,FONACT,DEFICO,RESOCO)
      ENDIF
C
  99  CONTINUE      
C      
      CALL JEDEMA()     
C
      END
