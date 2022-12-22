package io.agora.contacts.model;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;

import java.util.List;

import io.agora.service.model.ServiceViewModel;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.net.Resource;
import io.agora.service.repo.EMContactManagerRepository;
import io.agora.service.utils.SingleSourceLiveData;


public class ContactsListViewModel extends ServiceViewModel {
    private EMContactManagerRepository mRepository;

    private SingleSourceLiveData<Resource<List<CircleUser>>> contactObservable;
    private MediatorLiveData<Resource<List<CircleUser>>> blackObservable;
    private SingleSourceLiveData<Resource<Boolean>> blackResultObservable;
    private SingleSourceLiveData<Resource<Boolean>> deleteObservable;
    private SingleSourceLiveData<Resource<List<CircleUser>>> searchObservable;

    public ContactsListViewModel(@NonNull Application application) {
        super(application);
        mRepository = new EMContactManagerRepository();
        contactObservable = new SingleSourceLiveData<>();
        blackObservable = new MediatorLiveData<>();
        blackResultObservable = new SingleSourceLiveData<>();
        deleteObservable = new SingleSourceLiveData<>();
        searchObservable = new SingleSourceLiveData<>();
    }

    public LiveData<Resource<List<CircleUser>>> blackObservable() {
        return blackObservable;
    }



    public void loadContactList(boolean fetchServer) {
        contactObservable.setSource(mRepository.getContactList(fetchServer));
    }

    public void searchContact(String key) {
        searchObservable.setSource(mRepository.getSearchContacts(key));
    }

    public LiveData<Resource<List<CircleUser>>> getContactObservable() {
        return contactObservable;
    }

    public LiveData<Resource<Boolean>> resultObservable() {
        return blackResultObservable;
    }

    public LiveData<Resource<Boolean>> deleteObservable() {
        return deleteObservable;
    }

    public LiveData<Resource<List<CircleUser>>> getSearchObservable() {
        return searchObservable;
    }

    public void deleteContact(String username) {
        deleteObservable.setSource(mRepository.deleteContact(username));
    }

}
