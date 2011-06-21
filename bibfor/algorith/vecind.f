      SUBROUTINE VECIND(MAT,LVEC,NBL,NBC,FORCE,NINDEP)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/06/2011   AUTEUR CORUS M.CORUS 
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

C--------------------------------------------------------------------C
C  M. CORUS     DATE 09/06/11
C-----------------------------------------------------------------------
C  BUT : CONSTRUCTION D'UNE BASE A PARTIR DE VECTEURS QUELCONQUES :
C         - SELECTION D'UNE FAMILLE LIBRE
C         - ORTHONORMALISATION DE LA FAMILLE LIBRE
C
C
C  MAT     /I/   : NOM K19 DE LA MATRICE POUR CONSTRUIRE LA NORME
C  LVEC    /I-O/ : POINTEUR DE LA FAMILLE DE VECTEURS
C  NBL     /I/   : NOMBRE DE LIGNE DE CHAQUE VECTEUR
C  NBC     /I-O/ : NOMBRE DE VECTEURS
C  FORCE   /I/   : FORCE LA NORMALISATION SI VAUT 1
C  NINDEP  /O/   : NOMBRE DE VECTEUR INDEPENDANT EN SORTIE
C
C  NOTE : LA TAILLE DE LA MATRICE ASSOCIE A LVEC EST INCHANGEE EN SORTIE
C         MAIS LES DERNIERES COLONNES SONT MISES A ZERO 
C-----------------------------------------------------------------------
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C       
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
C
C-----  FIN  COMMUNS NORMALISES  JEVEUX  -------------------------------
C

      INTEGER      LVEC,NBL,NBC,NINDEP,LWORK,JWORK,LMAT,LTRAV1,LTRAV2,
     &             LTRAV3,JNSTA,I1,K1,L1,INFO,LCOPY,FORCE,INDNZ,VECNZ,
     &             IDEEQ
     
      REAL*8       SWORK,NORME,SQRT,DDOT,RIJ
      CHARACTER*8  ORTHO
      CHARACTER*19 MAT,NUME
      
      CALL WKVECT('&&VECIND.NEW_STAT','V V R',NBC*NBC,JNSTA)
      CALL WKVECT('&&VECIND.TRAV1'   ,'V V R',NBL,LTRAV1)
      CALL WKVECT('&&VECIND.VEC_IND_NZ','V V I',NBC,VECNZ)
      INDNZ=0  
      IF (MAT .NE. ' ') THEN
        CALL JEVEUO(MAT//'.&INT','L',LMAT)
      ENDIF

C-- NORMER LES MODES DANS L2 AVANT DE CONSTRUIRE LA MATRICE
C-- POUR PLUS DE ROBUSTESSE

      CALL WKVECT('&&VECIND.VECTEURS_COPIES','V V R',NBL*NBC,LCOPY)
      CALL WKVECT('&&VECIND.VECTEURS_TEMP','V V R',NBL,LTRAV1)
      
      CALL DISMOI('F','NOM_NUME_DDL',MAT(1:8),'MATR_ASSE',INFO,
     &              NUME,INFO)
      CALL JEVEUO(NUME(1:8)//'      .NUME.DEEQ','L',IDEEQ)
      
      DO 500 I1=1,NBC  
        IF (MAT .NE. ' ') THEN
          CALL ZERLAG(ZR(LVEC+NBL*(I1-1)),NBL,ZI(IDEEQ))
          CALL MRMULT('ZERO',LMAT,ZR(LVEC+NBL*(I1-1)),'R',
     &                ZR(LTRAV1),1)
          CALL ZERLAG(ZR(LTRAV1),NBL,ZI(IDEEQ))
          NORME=DDOT(NBL,ZR(LTRAV1),1,ZR(LVEC+NBL*(I1-1)),1)
          
        ELSE
          CALL ZERLAG(ZR(LVEC+NBL*(I1-1)),NBL,ZI(IDEEQ))
          NORME=DDOT(NBL,ZR(LVEC+NBL*(I1-1)),1,ZR(LVEC+NBL*(I1-1)),1)
        ENDIF
        NORME=SQRT(NORME)
        IF (NORME .GT. 1.D-16) THEN
          CALL DAXPY(NBL,1/NORME,ZR(LVEC+NBL*(I1-1)),1,
     &               ZR(LCOPY+NBL*(I1-1)),1)
        ELSE
          CALL DAXPY(NBL,0.D0,ZR(LVEC+NBL*(I1-1)),1,
     &               ZR(LCOPY+NBL*(I1-1)),1)
        ENDIF
 500  CONTINUE     

      DO 510 L1=1,NBC
        IF (MAT .NE. ' ') THEN
          CALL MRMULT('ZERO',LMAT,ZR(LCOPY+NBL*(L1-1)),'R',
     &                ZR(LTRAV1),1)
        ELSE
          CALL LCEQVN(NBL,ZR(LCOPY+NBL*(L1-1)),ZR(LTRAV1))
        ENDIF
        NORME=DDOT(NBL,ZR(LTRAV1),1,ZR(LCOPY+NBL*(L1-1)),1)
        ZR(JNSTA+(L1-1)*(NBC+1))=NORME
        DO 520 K1=L1+1,NBC
          RIJ=DDOT(NBL,ZR(LTRAV1),1,ZR(LCOPY+NBL*(K1-1)),1)
          ZR(JNSTA+(L1-1)*NBC+K1-1)=RIJ
          ZR(JNSTA+(K1-1)*NBC+L1-1)=RIJ
 520    CONTINUE
 510  CONTINUE
 
      IF (FORCE .NE. 1) THEN
C-- UTILISE APRES LE GRAM SCHMIDT DANS ORTH99, POUR
C-- ELIMINER LES VECTEURS NON INDEPENDANTS

        DO 550 L1=1,NBC
          NORME=ZR(JNSTA+(L1-1)*(NBC+1))
          
          IF (NORME .GT. 1.D-16) THEN 
            DO 560 K1=L1+1,NBC
              RIJ=ABS(ZR(JNSTA+(L1-1)*NBC+K1-1))
              RIJ=RIJ/NORME 
              IF (RIJ .GT. 1.D-8) THEN
                WRITE(6,*)' ... ANNULATION DU VECTEUR ',K1
                DO 570 I1=1,NBL
                  ZR(LVEC+((K1-1)*NBL)+I1-1)=0.D0
 570            CONTINUE
                DO 580 I1=1,NBC
                  ZR(JNSTA+((K1-1)*NBC)+I1-1)=0.D0
                  ZR(JNSTA+((I1-1)*NBC)+K1-1)=0.D0
 580            CONTINUE
              ENDIF
 560        CONTINUE
          ENDIF
          
 550    CONTINUE
 
        CALL GETVTX('  ','ORTHO',1,1,8,ORTHO,INFO)
        IF ((INFO .EQ. 1) .AND. (ORTHO.EQ.'OUI') ) THEN
C-- SELECTION DES VECTEURS NON NULS POUR REMPLIR LA BASE 
          DO 590 I1=1,NBC
            IF (ZR(JNSTA + (I1-1)*(NBC+1) ) .GT. 1D-10) THEN
              ZI(VECNZ+INDNZ)=I1
              INDNZ=INDNZ+1
            ENDIF 
 590      CONTINUE
 
          DO 600 I1=1,INDNZ
            CALL DAXPY(NBL,0.D0,ZR(LVEC+NBL*(I1-1)),1,
     &                 ZR(LVEC+NBL*(ZI(VECNZ+I1-1)-1)),1)
 600      CONTINUE
          NBC=INDNZ
        ENDIF
      ELSE
 
C-- ALLOCATION DES MATRICES DE TRAVAIL TEMPORAIRES
        CALL WKVECT('&&VECIND.TRAV1_S','V V R',NBC,LTRAV1)
        CALL WKVECT('&&VECIND.TRAV2_U','V V R',NBC*NBC,LTRAV2)
        CALL WKVECT('&&VECIND.TRAV3_V','V V R',NBC*NBC,LTRAV3)

C-- DESACTIVATION DU TEST FPE
        CALL MATFPE(-1)

        CALL DGESVD('A','N',NBC,NBC,ZR(JNSTA),NBC,ZR(LTRAV1),
     &              ZR(LTRAV2),NBC,ZR(LTRAV3),NBC,SWORK,-1,INFO)
        LWORK=INT(SWORK)
        CALL WKVECT('&&VECIND.MAT_SVD_WORK','V V R',LWORK,JWORK)

        CALL DGESVD('A','N',NBC,NBC,ZR(JNSTA),NBC,ZR(LTRAV1),
     &              ZR(LTRAV2),NBC,ZR(LTRAV3),NBC,ZR(JWORK),LWORK,INFO)

        NINDEP=0
        NORME=(NBC+0.D0)*ZR(LTRAV1)*1.D-16
        DO 530 K1=1,NBC
          IF (ZR(LTRAV1+K1-1) .GT. NORME) NINDEP=NINDEP+1
 530    CONTINUE

        CALL WKVECT('&&VECIND.MODE_INTF_DEPL','V V R',
     &              NBL*NBC,LMAT)

        CALL DGEMM('N','N',NBL,NINDEP,NBC,1.D0,ZR(LCOPY),
     &             NBL,ZR(LTRAV2),NBC,0.D0,ZR(LVEC),NBL)

        DO 540 I1=1,NBL*(NBC-NINDEP)
          ZR(LVEC+(NINDEP*NBL)+I1-1)=0.D0
 540    CONTINUE     
  
        CALL MATFPE(1)

        CALL JEDETR('&&VECIND.MAT_SVD_WORK')
        CALL JEDETR('&&VECIND.TRAV1_S')
        CALL JEDETR('&&VECIND.TRAV2_U')
        CALL JEDETR('&&VECIND.TRAV3_V')
        CALL JEDETR('&&VECIND.MODE_INTF_DEPL')
      
      ENDIF
      
        

      CALL JEDETR('&&VECIND.NEW_STAT')
      CALL JEDETR('&&VECIND.TRAV1')
      CALL JEDETR('&&VECIND.VECTEURS_COPIES')
      CALL JEDETR('&&VECIND.VECTEURS_TEMP') 
      CALL JEDETR('&&VECIND.VEC_IND_NZ')

      END
