//
//  COBJCObjectContainer.h
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#ifndef __Vectors__COBJCObjectContainer__
#define __Vectors__COBJCObjectContainer__

class COBJCObjectContainer {
    public:
        COBJCObjectContainer(id inObject)
            {
            NSCParameterAssert(inObject != NULL);

            mCFObject = (__bridge_retained CFTypeRef)inObject;
            }

        COBJCObjectContainer(const COBJCObjectContainer& other)
            {
            mCFObject = (__bridge_retained CFTypeRef)other.object();
            }

        COBJCObjectContainer(COBJCObjectContainer&& other)
            {
            mCFObject = other.mCFObject;
            other.mCFObject = NULL;
            }

        ~COBJCObjectContainer()
            {
            if (mCFObject != NULL)
                {
                CFRelease(mCFObject);
                mCFObject = NULL;
                }
            }

        COBJCObjectContainer &operator = (const COBJCObjectContainer& rhs)
            {
            if (this != &rhs)
                {
                if (mCFObject != NULL)
                    {
                    CFRelease(mCFObject);
                    mCFObject = NULL;
                    }

                mCFObject = (__bridge_retained CFTypeRef)rhs.object();
                }

            return *this;
            }

        COBJCObjectContainer &operator = (COBJCObjectContainer&& rhs)
            {
            if (this != &rhs)
                {
                if (mCFObject != NULL)
                    {
                    CFRelease(mCFObject);
                    mCFObject = NULL;
                    }

                mCFObject = rhs.mCFObject;
                rhs.mCFObject = NULL;
                }

            return *this;
            }

        id object(void) const
            {
            NSCParameterAssert(mCFObject != NULL);
            return (__bridge id)mCFObject;
            }
    protected:
        CFTypeRef mCFObject;
    };

#endif /* defined(__Vectors__COBJCObjectContainer__) */
