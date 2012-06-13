      SUBROUTINE NMASCO(TYPVEC,FONACT,DEFICO,VEASSE,CNCONT)
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
      CHARACTER*6   TYPVEC
      INTEGER       FONACT(*)   
      CHARACTER*24  DEFICO
      CHARACTER*19  VEASSE(*)
      CHARACTER*19  CNCONT      
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - CALCUL)
C
C CONSTRUCTION DU VECTEUR DES FORCES VARIABLES LIEES AU CONTACT
C      
C ----------------------------------------------------------------------
C
C
C IN  TYPVEC : TYPE DE VECTEUR APPELANT
C                'CNFINT' - FORCES INTERNES
C                'CNDIRI' - REACTIONS D'APPUI
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  DEFICO : SD DEFINITION CONTACT
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C OUT CNCONT : VECT_ASSE DES CONTRIBUTIONS DE CONTACT/FROTTEMENT (C/F)
C               C/F METHODE CONTINUE
C               C/F METHODE XFEM
C               C/F METHODE XFEM GRDS GLIS.
C               F   METHODE DISCRETE
C
C
C
C 
      LOGICAL      ISFONC,CFDISL,LELTC,LELTF,LCTFD,LPENAC,LALLV
      INTEGER      IFDO,N
      CHARACTER*19 VECT(20)
      REAL*8       COEF(20)      
      CHARACTER*19 CNCTDF,CNELTC,CNELTF
C 
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      IFDO   = 0    
      CALL VTZERO(CNCONT)   
C
C --- FONCTIONNALITES ACTIVEES
C     
      LELTC  = ISFONC(FONACT,'ELT_CONTACT')
      LELTF  = ISFONC(FONACT,'ELT_FROTTEMENT')
      LCTFD  = ISFONC(FONACT,'FROT_DISCRET')
      LPENAC = CFDISL(DEFICO,'CONT_PENA')
      LALLV  = ISFONC(FONACT,'CONT_ALL_VERIF'  )
C
C --- FORCES DE FROTTEMENT DISCRET
C
      IF (TYPVEC.EQ.'CNDIRI') THEN
        IF (((LCTFD).OR.(LPENAC)).AND.(.NOT.LALLV)) THEN
          CALL NMCHEX(VEASSE,'VEASSE','CNCTDF',CNCTDF) 
          IFDO       = IFDO + 1 
          COEF(IFDO) = 1.D0   
          VECT(IFDO) = CNCTDF
        ENDIF 
      ENDIF                     
C
C --- FORCES DES ELEMENTS DE CONTACT (XFEM+CONTINUE)
C
      IF (TYPVEC.EQ.'CNFINT') THEN
       IF (LELTC.AND.(.NOT.LALLV)) THEN
         CALL NMCHEX(VEASSE,'VEASSE','CNELTC',CNELTC)  
         IFDO       = IFDO + 1
         COEF(IFDO) = 1.D0   
         VECT(IFDO) = CNELTC 
       ENDIF  
       IF (LELTF.AND.(.NOT.LALLV)) THEN    
         CALL NMCHEX(VEASSE,'VEASSE','CNELTF',CNELTF)  
         IFDO       = IFDO + 1 
         COEF(IFDO) = 1.D0   
         VECT(IFDO) = CNELTF                    
       ENDIF
      ENDIF                  
C
C --- VECTEUR RESULTANT 
C       
      DO 10 N = 1,IFDO
        CALL VTAXPY(COEF(N),VECT(N),CNCONT)   
 10   CONTINUE       
C
      CALL JEDEMA()
      END
