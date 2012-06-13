      SUBROUTINE BMOCCA(UMOY,GEOM,CF0,MCF0,FSVR,NBM,VICOQ,TORCO,TCOEF,
     &                  S1,S2,B)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C-----------------------------------------------------------------------
C COUPLAGE FLUIDELASTIQUE, CONFIGURATIONS DU TYPE "COQUE_COAX"
C CALCUL DE LA MATRICE DE TRANSFERT DES FORCES FLUIDELASTIQUES
C PROJETEE SUR LA BASE MODALE DES STRUCTURES
C ROUTINE CHAPEAU
C APPELANT : MODEAU, PACOUF, POIBIJ
C-----------------------------------------------------------------------
C  IN : UMOY   : VITESSE DE L'ECOULEMENT MOYEN
C  IN : GEOM   : VECTEUR DE GRANDEURS GEOMETRIQUES CARACTERISTIQUES
C  IN : CF0    : COEFFICIENT DE FROTTEMENT VISQUEUX
C  IN : MCF0   : EXPOSANT VIS-A-VIS DU NOMBRE DE REYNOLDS
C  IN : FSVR   : OBJET .FSVR DU CONCEPT TYPE_FLUI_STRU
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : VICOQ  : VECTEUR D'INDICES CARACTERISANT LA COQUE EN MOUVEMENT
C                POUR CHAQUE MODE
C                VICOQ(IMOD)=1 COQUE INTERNE EN MVT POUR LE MODE IMOD
C                VICOQ(IMOD)=2 COQUE EXTERNE EN MVT
C                VICOQ(IMOD)=3 COQUES INTERNE + EXTERNE EN MVT
C  IN : TORCO  : TABLEAU DES ORDRES DE COQUE ET DEPHASAGES
C  IN : TCOEF  : TABLEAU DES COEFFICIENTS DES DEFORMEES AXIALES
C  IN : S1     : PARTIE REELLE DE LA FREQUENCE COMPLEXE A LAQUELLE ON
C                CALCULE LA MATRICE B(S)
C  IN : S2     : PARTIE IMAGINAIRE DE LA FREQUENCE COMPLEXE
C OUT : B      : MATRICE DE TRANSFERT DES FORCES FLUIDELASTIQUES
C                B(NBM,NBM) A COEFFICIENTS COMPLEXES
C-----------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'
      REAL*8      UMOY,GEOM(9),CF0,MCF0,FSVR(7)
      INTEGER     NBM,VICOQ(NBM)
      REAL*8      TORCO(4,NBM),TCOEF(10,NBM),S1,S2
      COMPLEX*16  B(NBM,NBM)
C
      REAL*8      LONG
      COMPLEX*16  BIJ1,BIJ2,BIJ11,BIJ12,BIJ21,BIJ22
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C
C --- 1.INITIALISATIONS ET CREATION DE VECTEURS DE TRAVAIL
C
      HMOY  = GEOM(1)
      RMOY  = GEOM(2)
      LONG  = GEOM(3)
C
      R1 = RMOY - HMOY/2.D0
      R2 = RMOY + HMOY/2.D0
C
      RHOF = FSVR(1)
C
      CALL WKVECT('&&BMOCCA.TEMP.YSOL' ,'V V C',3*101,IYSOL )
      CALL WKVECT('&&BMOCCA.TEMP.YSOL1','V V C',3*101,IYSOL1)
      CALL WKVECT('&&BMOCCA.TEMP.YSOL2','V V C',3*101,IYSOL2)
C
C
C --- 2.CALCUL DE LA MATRICE B(S)
C
      DO 10 IMOD = 1,NBM
C
        ICOQ = VICOQ(IMOD)
C
C-------SI UNE SEULE COQUE EST EN MOUVEMENT POUR LE MODE IMOD
C
        IF (ICOQ.LT.3) THEN
C
          ILIGNE = 1
          IF (ICOQ.EQ.2) ILIGNE = 3
          RKI = TORCO(ILIGNE,IMOD)
          KI = INT(RKI)
          THETAI = TORCO(ILIGNE+1,IMOD)
C
C---------RESOLUTION DU PROBLEME FLUIDE POUR UN MOUVEMENT SUIVANT LE
C---------MODE IMOD DE LA COQUE ICOQ
C
          CALL PBFLUI(UMOY,HMOY,RMOY,LONG,CF0,MCF0,FSVR,ICOQ,IMOD,NBM,
     &                RKI,TCOEF,S1,S2,ZC(IYSOL))
C
          DO 20 JMOD = 1,NBM
C
            JCOQ = VICOQ(JMOD)
C
C-----------SI UNE SEULE COQUE EST EN MOUVEMENT POUR LE MODE JMOD
C
            IF (JCOQ.LT.3) THEN
C
              JLIGNE = 1
              IF (JCOQ.EQ.2) JLIGNE = 3
              RKJ = TORCO(JLIGNE,JMOD)
              KJ = INT(RKJ)
              THETAJ = TORCO(JLIGNE+1,JMOD)
              IF (KI.EQ.KJ) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,ICOQ,JCOQ,JMOD,NBM,
     &                      RKI,THETAI,THETAJ,TCOEF,ZC(IYSOL),
     &                      B(IMOD,JMOD))
              ELSE
                B(IMOD,JMOD) = DCMPLX(0.D0,0.D0)
              ENDIF
C
C-----------SINON (LES DEUX COQUES SONT EN MOUVEMENT POUR LE MODE JMOD)
C
            ELSE
C
              RK1J = TORCO(1,JMOD)
              K1J = INT(RK1J)
              THET1J = TORCO(2,JMOD)
              IF (KI.EQ.K1J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,ICOQ,1,JMOD,NBM,
     &                      RKI,THETAI,THET1J,TCOEF,ZC(IYSOL),BIJ1)
              ELSE
                BIJ1 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              RK2J = TORCO(3,JMOD)
              K2J = INT(RK2J)
              THET2J = TORCO(4,JMOD)
              IF (KI.EQ.K2J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,ICOQ,2,JMOD,NBM,
     &                      RKI,THETAI,THET2J,TCOEF,ZC(IYSOL),BIJ2)
              ELSE
                BIJ2 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              B(IMOD,JMOD) = BIJ1 + BIJ2
C
            ENDIF
C
  20      CONTINUE
C
C-------SINON (LES DEUX COQUES SONT EN MOUVEMENT POUR LE MODE IMOD)
C
        ELSE
C
          RK1I = TORCO(1,IMOD)
          K1I = INT(RK1I)
          THET1I = TORCO(2,IMOD)
C
C---------RESOLUTION DU PROBLEME FLUIDE POUR UN MOUVEMENT SUIVANT LE
C---------MODE IMOD DE LA COQUE 1 (COQUE INTERNE)
C
          CALL PBFLUI(UMOY,HMOY,RMOY,LONG,CF0,MCF0,FSVR,1,IMOD,NBM,
     &                RK1I,TCOEF,S1,S2,ZC(IYSOL1))
C
          RK2I = TORCO(3,IMOD)
          K2I = INT(RK2I)
          THET2I = TORCO(4,IMOD)
C
C---------RESOLUTION DU PROBLEME FLUIDE POUR UN MOUVEMENT SUIVANT LE
C---------MODE IMOD DE LA COQUE 2 (COQUE EXTERNE)
C
          CALL PBFLUI(UMOY,HMOY,RMOY,LONG,CF0,MCF0,FSVR,2,IMOD,NBM,
     &                RK2I,TCOEF,S1,S2,ZC(IYSOL2))
C
          DO 30 JMOD = 1,NBM
C
            JCOQ = VICOQ(JMOD)
C
C-----------SI UNE SEULE COQUE EST EN MOUVEMENT POUR LE MODE JMOD
C
            IF (JCOQ.LT.3) THEN
C
              JLIGNE = 1
              IF (JCOQ.EQ.2) JLIGNE = 3
              RKJ = TORCO(JLIGNE,JMOD)
              KJ = INT(RKJ)
              THETAJ = TORCO(JLIGNE+1,JMOD)
C
              IF (K1I.EQ.KJ) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,1,JCOQ,JMOD,NBM,
     &                      RK1I,THET1I,THETAJ,TCOEF,ZC(IYSOL1),BIJ1)
              ELSE
                BIJ1 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              IF (K2I.EQ.KJ) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,2,JCOQ,JMOD,NBM,
     &                      RK2I,THET2I,THETAJ,TCOEF,ZC(IYSOL2),BIJ2)
              ELSE
                BIJ2 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              B(IMOD,JMOD) = BIJ1 + BIJ2
C
C-----------SINON (LES DEUX COQUES SONT EN MOUVEMENT POUR LE MODE JMOD)
C
            ELSE
C
              RK1J = TORCO(1,JMOD)
              K1J = INT(RK1J)
              THET1J = TORCO(2,JMOD)
C
              IF (K1I.EQ.K1J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,1,1,JMOD,NBM,RK1I,
     &                      THET1I,THET1J,TCOEF,ZC(IYSOL1),BIJ11)
              ELSE
                BIJ11 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              IF (K2I.EQ.K1J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,2,1,JMOD,NBM,RK2I,
     &                      THET2I,THET1J,TCOEF,ZC(IYSOL2),BIJ21)
              ELSE
                BIJ21 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              RK2J = TORCO(3,JMOD)
              K2J = INT(RK2J)
              THET2J = TORCO(4,JMOD)
C
              IF (K1I.EQ.K2J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,1,2,JMOD,NBM,RK1I,
     &                      THET1I,THET2J,TCOEF,ZC(IYSOL1),BIJ12)
              ELSE
                BIJ12 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              IF (K2I.EQ.K2J) THEN
                CALL BIJSOM(UMOY,RHOF,R1,R2,LONG,CF0,2,2,JMOD,NBM,RK2I,
     &                      THET2I,THET2J,TCOEF,ZC(IYSOL2),BIJ22)
              ELSE
                BIJ22 = DCMPLX(0.D0,0.D0)
              ENDIF
C
              B(IMOD,JMOD) = BIJ11 + BIJ21 + BIJ12 + BIJ22
C
            ENDIF
C
  30      CONTINUE
C
        ENDIF
C
  10  CONTINUE
C
      CALL JEDETR('&&BMOCCA.TEMP.YSOL')
      CALL JEDETR('&&BMOCCA.TEMP.YSOL1')
      CALL JEDETR('&&BMOCCA.TEMP.YSOL2')
      CALL JEDEMA()
      END
