      SUBROUTINE FETFIV(NBSD,NBI,VD1,VD2,VDO,MATAS,VSDF,VDDL,COLAUX,
     &                  COLAUI,SDFETI)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/01/2005   AUTEUR BOITEAU O.BOITEAU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  CALCUL DU PRODUIT OPERATEUR_FETI * V
C
C      IN   NBSD: IN   : NOMBRE DE SOUS-DOMAINES
C      IN    NBI: IN   : NOMBRE DE NOEUDS D'INTERFACE
C      IN    VD1: VR8  : VECTEUR V DE TAILLE NBI 
C      IN    VD2: VR8  : VECTEUR AUXILIAIRE DE TAILLE NBI
C      OUT   VDO: VR8  : VECTEUR OUTPUT DE TAILLE NBI
C      IN  MATAS: CH19 : NOM DE LA MATR_ASSE GLOBALE
C      IN   VSDF: VIN  : VECTEUR MATR_ASSE.FETF INDIQUANT SI 
C                         SD FLOTTANT
C      IN   VDDL: VIN  : VECTEUR DES NBRES DE DDLS DES SOUS-DOMAINES
C      IN COLAUX: COL  : NOM DE LA COLLECTION AUXILAIRE
C      IN COLAUI: COL  : COLLECTION TEMPORAIRE D'ENTIER
C      IN SDFETI: CH19 : SD DECRIVANT LE PARTIONNEMENT FETI
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       26/01/04 (OB): CREATION.
C       04/06/04 (OB): TRAITEMENT DES MODES DE CORPS RIGIDES
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBSD,NBI,VDDL(NBSD),VSDF(NBSD)
      REAL*8       VD1(NBI),VD2(NBI),VDO(NBI)
      CHARACTER*19 MATAS,SDFETI
      CHARACTER*24 COLAUX,COLAUI
      
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      
C DECLARATION VARIABLES LOCALES
      INTEGER      IDD,IFETM,NBDDL,IDD1,JXSOL,J,TYPSYM,OPTION,IFM,NIV,
     &             NBSOL,LMAT,NBBLOC,NBSDF,NBMC,IFETP,NBMC1,JXSOL1,IINF,
     &             IAUXJ
      CHARACTER*19 MATDD
      CHARACTER*24 NOMSDP,INFOFE
      CHARACTER*32 JEXNUM
            
C CORPS DU PROGRAMME
      CALL JEMARQ()

C RECUPERATION DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)
      CALL JEVEUO('&&'//SDFETI(1:17)//'.FINF','L',IINF)
      INFOFE=ZK24(IINF)
      
C INIT. NBRE DE SECOND MEMBRES SOLUTION POUR RLTFR8
      NBSOL=1

C INIT. NOM OBJET JEVEUX POUR PRODUIT PAR PSEUDO-INVERSE LOCALE      
      NOMSDP=MATAS//'.FETP'
            
C INIT. VECTEUR SOLUTION ET AUX
      DO 10 J=1,NBI
        VDO(J)=0.D0
   10 CONTINUE         
C OBJET JEVEUX POINTANT SUR LA LISTE DES MATR_ASSE
      CALL JEVEUO(MATAS//'.FETM','L',IFETM)
      
C --------------------------------------------------------------------
C ----  BOUCLE SUR LES SOUS-DOMAINES
C --------------------------------------------------------------------
C NOMBRE DE SOUS-DOMAINES FLOTTANTS      
      NBSDF=0 
      DO 40 IDD=1,NBSD
        CALL JEMARQ()
        IDD1=IDD-1
        
C MATR_ASSE ASSOCIEE AU SOUS-DOMAINE IDD      
        MATDD=ZK24(IFETM+IDD1)(1:19)
C DESCRIPTEUR DE LA MATRICE DU SOUS-DOMAINE     
        CALL JEVEUO(MATDD//'.&INT','L',LMAT)
C NOMBRE DE BLOC DE STOCKAGE DE LA MATRICE KI/ TYPE DE SYMETRIE
        NBBLOC=ZI(LMAT+13)
        TYPSYM=ZI(LMAT+4)                       
C NBRE DE DDL DU SOUS-DOMAINE IDD       
        NBDDL=VDDL(IDD)
C VECTEUR AUXILIAIRE DE TAILLE NDDL(SOUS_DOMAINE_IDD)     
        CALL JEVEUO(JEXNUM(COLAUX,IDD),'E',JXSOL)
                
C EXTRACTION DU VECTEUR V AU SOUS-DOMAINE IDD: (RIDD)T * V
        OPTION=2        
        CALL FETREX(OPTION,IDD,NBI,VD1,NBDDL,ZR(JXSOL),SDFETI,COLAUI)

C SCALING VIA ALPHA DES COMPOSANTES DU SECOND MEMBRE DUES AUX LAGRANGES
C SYSTEME: K * U= ALPHA * F ---> K * U/ALPHA = F
        CALL MRCONL(LMAT,0,'R',ZR(JXSOL),1)                        
C -------------------------------------------------
C ----  SOUS-DOMAINE NON FLOTTANT
C -------------------------------------------------
C NOMBRES DE MODES DE CORPS RIGIDES DU SOUS-DOMAINE IDD
        NBMC=VSDF(IDD)     
        IF (NBMC.EQ.-1) THEN 

C CALCUL DE (KIDD)- * FIDD PAR MULT_FRONT  
          CALL RLTFR8(MATDD,NBDDL,ZR(JXSOL),NBSOL,TYPSYM)
          
C MONITORING
          IF (INFOFE(1:1).EQ.'T') THEN
            WRITE(IFM,*)
            WRITE(IFM,*)'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
            WRITE(IFM,*)'<FETI/FETFIV> CALCUL (KI)-*(RI)T*V POUR I= ',
     &                IDD
            WRITE(IFM,*)'<FETI/FETFIV> NBDDL/NBBLOC/TYPSYM',
     &                NBDDL,NBBLOC,TYPSYM
          ENDIF         

        ELSE
C -------------------------------------------------
C ----  SOUS-DOMAINE FLOTTANT
C -------------------------------------------------
          NBSDF=NBSDF+1
C CALCUL DE (KI)+FI PAR MULT_FRONT 
          CALL RLTFR8(MATDD,NBDDL,ZR(JXSOL),NBSOL,TYPSYM)
          CALL JEVEUO(JEXNUM(NOMSDP,NBSDF),'L',IFETP)
          
          NBMC1=NBMC-1
          JXSOL1=JXSOL-1
          DO 25 J=0,NBMC1
            IAUXJ=ZI(IFETP+J)
            ZR(JXSOL1+IAUXJ)=0.D0   
   25     CONTINUE
   
C MONITORING
          IF (INFOFE(1:1).EQ.'T') THEN
            WRITE(IFM,*)
            WRITE(IFM,*)'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
           WRITE(IFM,*)'<FETI/FETFIV> CALCUL (KI)+*(RI)T*V I= ',
     &        IDD
            WRITE(IFM,*)'NBDDL/NBBLOC/TYPSYM',NBDDL,NBBLOC,TYPSYM
            WRITE(IFM,*)'NBMC/NBSDF',NBMC,NBSDF
          ENDIF
        ENDIF
C SCALING DES COMPOSANTES DE ZR(LXSOL) POUR CONTENIR LA SOL. REELLE U
        CALL MRCONL(LMAT,0,'R',ZR(JXSOL),1)

C RESTRICTION DU SOUS-DOMAINE IDD SUR L'INTERFACE: (RIDD) * ...
        OPTION=1        
        CALL FETREX(OPTION,IDD,NBDDL,ZR(JXSOL),NBI,VD2,SDFETI,COLAUI)  
C CUMUL DANS LE VECTEUR VDO=SOMME(I=1,NBSD)(RI * ((KI)+ * RIT * V))
        CALL DAXPY(NBI,1.D0,VD2,1,VDO,1)

C MONITORING
        IF (INFOFE(1:1).EQ.'T') THEN
          WRITE(IFM,*)'<FETI/FETFIV> CUMUL  FIV = FIV +'//
     &                ' RI*((KI)+*(RIT*V)) '      
          WRITE(IFM,*)'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
        ENDIF
        CALL JEDEMA()         
   40 CONTINUE             
      CALL JEDEMA()
      END
