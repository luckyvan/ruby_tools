// HahaTest.cpp

#ifndef HAHATEST_H
#define HAHATEST_H

#include <cppunit/extensions/HelperMacros.h>

class HahaTest : public CPPUNIT_NS::TestFixture
{
    CPPUNIT_TEST_SUITE( HahaTest );
    //CPPUNIT_TEST(test_$func);
    //CPPUNIT_TEST_EXCEPTION(test_$exception_func, exception);
    CPPUNIT_TEST_SUITE_END();

public: 
   void setUp();
   void tearDown();

   //void test_$func();
   //void test_$exception_func();
};
#endif
