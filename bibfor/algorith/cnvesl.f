      SUBROUTINE CNVESL(LISCHA,TYPRES,NEQ   ,NOMPAR,VALPAR,
     &                  CNVASS)
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
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*19 LISCHA
      CHARACTER*19 CNVASS
      CHARACTER*1  TYPRES
      CHARACTER*8  NOMPAR
      INTEGER      NEQ
      REAL*8       VALPAR
C
C ----------------------------------------------------------------------
C
C CALCUL CONTRIBUTION SECOND MEMBRE SI VECT_ASSE
C
C ----------------------------------------------------------------------
C
C
C IN  LISCHA : SD LISTE DES CHARGES
C IN  TYPRES : TYPE DU CHAM_NO RESULTANT 'C'
C IN  NOMPAR : NOM DU PARAMETRE
C IN  VALPAR : VALEUR DU PARAMETRE
C IN  NEQ    : NOMBRE D'EQUATIONS DU SYSTEME
C OUT CNVASS : NOM DU CHAMP
C
C
C
C
      INTEGER      ICHAR,NBCHAR
      INTEGER      LISNBG,NBVEAS,NBVEAG,NBTOT,IRET,IEQ
      INTEGER      CODCHA
      INTEGER      JRESU,JVALE
      CHARACTER*16 TYPFCT
      CHARACTER*8  NOMFCT,CHARGE,TYPECH
      REAL*8       VALRE,VALIM
      COMPLEX*16   CALPHA,CALP
      REAL*8       PHASE,OMEGA,R8DEPI,R8DGRD
      INTEGER      NPUIS
      LOGICAL      LISICO,LVEAS,LVEAG
      CHARACTER*24 CHAMNO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      CALL ASSERT(TYPRES.EQ.'C')
      OMEGA = R8DEPI()*VALPAR
      CALL JEVEUO(CNVASS(1:19)//'.VALE','E',JRESU)
      DO 5 IEQ  = 1,NEQ
        ZC(JRESU-1+IEQ) = DCMPLX(0.D0,0.D0)
  5   CONTINUE
C
C --- NOMBRE DE CHARGEMENTS
C
      CALL LISNNB(LISCHA,NBCHAR)
C
C --- NOMBRE DE CHARGES DE TYPE VECT_ASSE
C
      NBVEAS = LISNBG(LISCHA,'VECT_ASSE'     )
      NBVEAG = LISNBG(LISCHA,'VECT_ASSE_GENE')
      NBTOT  = NBVEAS+NBVEAG
      IF (NBTOT.EQ.0) GOTO 999
C
C --- BOUCLE SUR LES CHARGES
C
      DO 10 ICHAR = 1,NBCHAR
C
C ----- CODE DU GENRE DE LA CHARGE
C
        CALL LISLCO(LISCHA,ICHAR ,CODCHA)
C
C ----- FONCTION MULTIPLICATRICE
C
        CALL LISLNF(LISCHA,ICHAR ,NOMFCT)
        CALL LISLTF(LISCHA,ICHAR ,TYPFCT)
C
C ----- MULTIPLICATEUR COMPLEXE
C
        CALL LISCPP(LISCHA,ICHAR ,PHASE ,NPUIS )
C
        LVEAS  = LISICO('VECT_ASSE'     ,CODCHA)
        LVEAG  = LISICO('VECT_ASSE_GENE',CODCHA)
        IF (LVEAS.OR.LVEAG) THEN
          CALL LISLCH(LISCHA,ICHAR ,CHARGE)
          CALL LISLTC(LISCHA,ICHAR ,TYPECH)
          CHAMNO = CHARGE
          
          VALRE  = 1.D0
          VALIM  = 0.D0
          IF (NOMFCT.NE.' ') THEN
            IF (TYPFCT(7:10).EQ.'REEL') THEN
              CALL FOINTE('F'   ,NOMFCT,1     ,NOMPAR,VALPAR,
     &                    VALRE ,IRET)
              VALIM = 0.D0
            ELSEIF  (TYPFCT(7:10).EQ.'COMP') THEN
              CALL FOINTC('F'   ,NOMFCT,1     ,NOMPAR,VALPAR,
     &                    VALRE ,VALIM ,IRET  )
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
          ENDIF
          CALP   = DCMPLX(VALRE,VALIM)
          CALPHA = CALP*EXP(DCMPLX(0.D0,PHASE*R8DGRD()))
          IF (NPUIS.NE.0) THEN
            CALPHA = CALPHA * OMEGA**NPUIS
          ENDIF
          CALL JEVEUO(CHAMNO(1:19)//'.VALE','L',JVALE)
          IF ( TYPECH .EQ. 'COMP' ) THEN
            DO 122 IEQ  = 1,NEQ
              ZC(JRESU-1+IEQ) = ZC(JRESU-1+IEQ) +
     &                           CALPHA*ZC(JVALE-1+IEQ)
  122       CONTINUE
          ELSE
            DO 123 IEQ  = 1,NEQ
              ZC(JRESU-1+IEQ) = ZC(JRESU-1+IEQ) +
     &                           CALPHA*ZR(JVALE-1+IEQ)
  123       CONTINUE
          ENDIF
        ENDIF
 10   CONTINUE
C
 999  CONTINUE
C
      CALL JEDEMA()
      END
